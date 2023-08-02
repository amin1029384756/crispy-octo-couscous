import UIKit
import YPImagePicker
import Photos
import ImageViewer_swift
import Toast_Swift

class HostBecome3Screen: ScreenWithInput<HostBecome3Layout, HostBecome3Arguments> {
    private var category: CategoryResponseResult!
    private var subcategory: SubcategoryResponseResult!
    private var attachedMedias: [FileWithMetadata] = []
    private var updatingExperience: ExperienceIndexResponseResult?
    
    private var plusHintShown = false

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        layout.startObservingKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        layout.endEditing(true)
        layout.stopObserving()

        super.viewWillDisappear(animated)
    }

    private func uploadNextMedia(index: Int, medias: [FileWithMetadata], delegate: @escaping () -> Void) {
        guard let experienceId = updatingExperience?.id,
              index < medias.count
        else {
            delegate()
            return
        }

        let fileWithMetadata = medias[index]
        UploadAddMediaToExperienceRequest(experienceId: experienceId, file: fileWithMetadata)
            .performRequestWithDelegate { [weak self] response, error in
            self?.uploadNextMedia(index: index + 1, medias: medias, delegate: delegate)
        }
    }

    private func createVideoOnly(languageId: Int) {
        let cal = Calendar(identifier: .gregorian)
        let endDate = cal.date(byAdding: .year, value: 100, to: Date())!
        navigator.navigate(
            to: HostAdReviewScreen.self,
            argument: HostCalendarArguments(
                category: category,
                subcategory: subcategory,
                description: layout.descriptionTextView.text ?? "",
                languageId: languageId,
                attachedMedias: attachedMedias,
                startDate: Date(),
                endDate: endDate,
                timeSlots: [],
                hostInfo: layout.hostInfo.get()
            )
        )
    }

    private func update(existingExperience: ExperienceIndexResponseResult) {
        let mediaIdsToDelete = existingExperience.medias?.filter { media in
            if media.isThumb {
                return false
            } else {
                return !attachedMedias.contains(where: { media.id == $0.existingMediaId })
            }
        }.map { $0.id } ?? []

        let languageId = Lang.list
                .first(where: { $0.language == layout.languageSelectionBox.selection } )?.id

        let experienceId = existingExperience.id

        loader.show(text: "Updating your experience")
        Task {
            do {
                _ = try await ExperienceUpdateRequest(
                    experienceModel: ExperienceUpdateModel(
                        id: existingExperience.id,
                        category_id: self.subcategory?.id ?? existingExperience.category_id,
                        language_id: languageId ?? 1,
                        description: layout.descriptionTextView.text ?? existingExperience.description,
                        introductory_video: nil,
                        sessions: existingExperience.sessions ?? [],
                        host_info: self.layout.hostInfo.get()
                    ),
                    deleteMedias: mediaIdsToDelete
                ).performRequest()

                let mediasToUpload = attachedMedias.filter { $0.existingMediaId == nil
                }
                if mediasToUpload.isEmpty {
                    await MainActor.run {
                        loader.dismiss()
                        navigator.navigate(
                            to: HostCalendarUpdateScreen.self,
                            argument: existingExperience
                        )
                    }
                    return
                }

                var mediaParams = [AddMediasToExperienceMediaRequestParams]()
                var mediaIdx = 1
                for fileWithMetadata in mediasToUpload {
                    loader.change(text: "Uploading photo \(mediaIdx) of \(mediasToUpload.count)")
                    let mimeType = fileWithMetadata.mimeType ?? "application/octet-stream"
                    let uploadRequest = ExperienceUploadRequest(
                        experienceId: experienceId,
                        data: fileWithMetadata.data,
                        mimeType: mimeType
                    )

                    let key = uploadRequest.key
                    let url = try await uploadRequest.performUpload()
                    mediaParams.append(AddMediasToExperienceMediaRequestParams(
                        file_name: (key as NSString).lastPathComponent,
                        mime_type: mimeType,
                        url: url.absoluteString,
                        key_s3: key
                    ))
                    print("Uploaded media \(mediaIdx)")
                    mediaIdx += 1
                }

                _ = try await AddMediasToExperienceRequest(
                    experienceId: experienceId,
                    medias: mediaParams
                ).performRequest()

                await MainActor.run {
                    loader.dismiss()
                    navigator.navigate(
                        to: HostCalendarUpdateScreen.self,
                        argument: existingExperience
                    )
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    func goNext() {
        let languageId = Lang.list
                .first(where: { $0.language == layout.languageSelectionBox.selection } )?.id

        if let existingExperience = updatingExperience {
            loader.show()
            update(existingExperience: existingExperience)
            return
        }

        if attachedMedias.isEmpty {
            self.show(error: "Photo or video is not selected")
            return
        }

        if subcategory.isVideoOnly {
            createVideoOnly(languageId: languageId ?? 1)
            return
        }

        navigator.navigate(to: HostBookingScreen.self,
            argument: HostBookingArguments(
                category: category,
                subcategory: subcategory,
                description: layout.descriptionTextView.text ?? "",
                languageId: languageId ?? 1,
                attachedMedias: attachedMedias,
                hostInfo: layout.hostInfo.get()
            )
        )
    }

    override func input(_ argument: HostBecome3Arguments) {
        category = argument.category
        subcategory = argument.subcategory
        updatingExperience = argument.updatingExperience

        if subcategory.isVideoOnly {
            layout.durationTextField.text = "n/a"
            layout.priceTextField.text = "n/a"
        } else {
            layout.durationTextField.text = "\(category.duration)"
            layout.priceTextField.text = String(format: "%.02f", category.price)
        }
        layout.descriptionTextView.text = argument.updatingExperience?.description ?? ""

        if let updatingExperience = updatingExperience {
            if let medias = updatingExperience.medias,
               !medias.isEmpty {
                attachedMedias = medias
                    .filter {
                        !$0.isThumb
                    }
                    .map { media in
                        var thumbUrl = URL(string: media.url)
                        if media.mimeType.starts(with: "video") {
                            let thumb = medias.first(where: {
                                $0.fileName == media.fileName + ".thumb.jpg"
                            })
                            thumbUrl = URL(string: thumb?.url ?? "")
                        }

                        return FileWithMetadata(
                            existingMediaId: media.id,
                            data: Data(),
                            mimeType: media.mimeType,
                            fileName: media.fileName,
                            localUrl: thumbUrl,
                            thumbnail: nil
                        )
                    }
                if let lastUrlString = medias
                        .last(where: { $0.mimeType.starts(with: "image") })?.url,
                   let lastUrl = URL(string: lastUrlString) {
                    layout.videoThumbnail.kf.setImage(with: lastUrl)
                }
            } else if let video = updatingExperience.video,
                      let url = video.urlFull {
                // Old version. Convert
                loader.show()
                layout.videoThumbnail.kf.setImage(with: url) { [weak self] result in
                    guard let self = self else { return }
                    self.loader.dismiss()
                    switch result {
                    case .success(let image):
                        let data = image.image.jpegData(compressionQuality: 0.8)!
                        let dirPath = self.getDocumentDirectoryPath()
                        let tempName = "\(Date().timeIntervalSince1970).jpg"
                        let imageFileUrl = URL(fileURLWithPath: dirPath.appendingPathComponent(tempName) as String)
                        do {
                            try data.write(to: imageFileUrl)
                            print("Successfully saved image at path: \(imageFileUrl)")
                            self.attachedMedias.append(
                                FileWithMetadata(
                                    existingMediaId: nil,
                                    data: data,
                                    mimeType: "image/jpeg",
                                    fileName: tempName,
                                    localUrl: imageFileUrl,
                                    thumbnail: image.image
                                )
                            )
                        } catch {
                            print("Error saving image: \(error)")
                        }

                    default:
                        break
                    }
                }
            }

            let mediasCount = attachedMedias.count
            if mediasCount > 0 {
                prepareGallery()
            } else {
                deactivateGallery()
            }
            layout.addBadge.isHidden = mediasCount == 0 || mediasCount >= 5
            layout.amountBadge.text = "\(mediasCount)"
            layout.amountBadge.isHidden = mediasCount == 0
        }

        if let hostInfo = argument.updatingExperience?.hostInfo ?? User.active?.profile.hostInfo {
            layout.hostInfo.set(hostInfo: hostInfo)
        }

    }

    private func openMediaSelector() {
        withCameraAccess { [weak self] in
            self?.openMediaSelectorWithPermission()
        }
    }

    private func openMediaSelectorWithPermission() {
        var config = YPImagePickerConfiguration()
        if subcategory.isVideoOnly {
            config.screens = [.library, .video]
            config.library.mediaType = .video
            config.video.trimmerMinDuration = 10.0
            config.video.trimmerMaxDuration = 120.0
        } else {
            config.screens = [.library, .video, .photo]
            config.library.mediaType = .photoAndVideo
            config.video.trimmerMinDuration = 1.0
            config.video.trimmerMaxDuration = 15.0
        }
        config.video.fileType = .mp4

        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker, weak self] items, _ in
            guard let self = self else { return }
            if let video = items.singleVideo {
                if let data = try? Data(contentsOf: video.url) {
                    self.attachedMedias.append(
                        FileWithMetadata(
                            existingMediaId: nil,
                            data: data,
                            mimeType: video.url.absoluteString.mimeType,
                            fileName: video.url.lastPathComponent,
                            localUrl: video.url,
                            thumbnail: video.thumbnail)
                    )
                    let mediasCount = self.attachedMedias.count
                    if mediasCount > 0 {
                        self.prepareGallery()
                    }
                    self.layout.showVideo(thumb: video.thumbnail)
                    self.layout.addBadge.isHidden = mediasCount == 0 || mediasCount >= 5
                    self.layout.amountBadge.text = "\(mediasCount)"
                    self.layout.amountBadge.isHidden = mediasCount == 0
                }
            } else if let photo = items.singlePhoto {
                // Save image to temporary file
                var image = photo.image
                if image.size.width > 1024 || image.size.height > 1024 {
                    image = image.resized(maxSize: 1024) ?? image
                }
                if let data = image.jpegData(compressionQuality: 0.8) {
                    let dirPath = self.getDocumentDirectoryPath()
                    let tempName = "\(Date().timeIntervalSince1970).jpg"
                    let imageFileUrl = URL(fileURLWithPath: dirPath.appendingPathComponent(tempName) as String)
                    do {
                        try data.write(to: imageFileUrl)
                        print("Successfully saved image at path: \(imageFileUrl)")
                        self.attachedMedias.append(
                            FileWithMetadata(
                                existingMediaId: nil,
                                data: data,
                                mimeType: "image/jpeg",
                                fileName: tempName,
                                localUrl: imageFileUrl,
                                thumbnail: image
                            )
                        )
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
                let mediasCount = self.attachedMedias.count
                if mediasCount > 0 {
                    self.prepareGallery()
                }
                self.layout.showVideo(thumb: photo.image)
                self.layout.addBadge.isHidden = mediasCount == 0 || mediasCount >= 5
                self.layout.amountBadge.text = "\(mediasCount)"
                self.layout.amountBadge.isHidden = mediasCount == 0
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }

    func prepareGallery() {
        layout.introductoryVideoSelectButton.isHidden = true
        layout.videoThumbnail.gestureRecognizers?.removeAll()
        layout.videoThumbnail.setupImageViewer(
            datasource: self,
            initialIndex: attachedMedias.count - 1,
            options: [
                .rightNavItemTitle("Delete") { idx in
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

                    if var topController = keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }

                        topController.dismiss(animated: true)
                    }

                    self.attachedMedias.remove(at: idx)
                    if let lastAttachment = self.attachedMedias.last {
                        if let thumb = lastAttachment.thumbnail {
                            self.layout.videoThumbnail.image = thumb
                        } else if let url = lastAttachment.localUrl {
                            self.layout.videoThumbnail.kf.setImage(with: url)
                        }
                    } else {
                        self.layout.videoThumbnail.image = nil
                    }

                    if self.attachedMedias.count == 0 {
                        self.deactivateGallery()
                    } else {
                        self.prepareGallery()
                    }
                }
            ],
            from: self)
        let mediasCount = attachedMedias.count
        layout.addBadge.isHidden = mediasCount == 0 || mediasCount >= 5
        layout.amountBadge.text = "\(mediasCount)"
        layout.amountBadge.isHidden = mediasCount == 0

        if mediasCount == 1, !plusHintShown {
            plusHintShown = true
            let photoOrVideo = (attachedMedias[0].mimeType ?? "").starts(with: "video") ? "video" : "Photo"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak layout] in
                layout?.makeToast(
                    "Tap ⊕ to add more. You can add up to 5 photos",
                    duration: 5.0,
                    position: .top,
                    title: "\(photoOrVideo) was added to your experience!",
                    image: nil,
                    style: ToastStyle(),
                    completion: nil
                )
            }
        }
    }

    func deactivateGallery() {
        layout.introductoryVideoSelectButton.isHidden = false
        layout.videoThumbnail.gestureRecognizers?.removeAll()
        let mediasCount = attachedMedias.count
        layout.addBadge.isHidden = mediasCount == 0 || mediasCount >= 5
        layout.amountBadge.text = "\(mediasCount)"
        layout.amountBadge.isHidden = mediasCount == 0
    }

    func addIntroductoryVideo() {
        openMediaSelector()
    }
}

extension HostBecome3Screen: ImageDataSource {
    func numberOfImages() -> Int {
        attachedMedias.count
    }

    func imageItem(at index: Int) -> ImageViewer_swift.ImageItem {
        let attachedMedia = attachedMedias[index]
        if attachedMedia.existingMediaId == nil {
            // New. Should have UIImage
            return .image(attachedMedia.thumbnail)
        } else {
            // Old. Use URL
            return .url(attachedMedia.localUrl!, placeholder: attachedMedia.thumbnail)
        }
    }
}

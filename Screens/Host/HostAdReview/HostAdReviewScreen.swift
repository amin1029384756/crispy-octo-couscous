import UIKit

class HostAdReviewScreen: ScreenWithInput<HostAdReviewLayout, HostCalendarArguments> {
    var argument: HostCalendarArguments!
    var acceptedTerms = false
    var confirmedAge = false

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func generateAd() {
        if !acceptedTerms {
            show(error: "Accept our terms of use and privacy policy before creating an ad")
            return
        }

        if !confirmedAge {
            show(error: "You must confirm that you're at least 18 years old")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let sessions = argument?
                .generateSessionDates()
                .map {
                    ExperienceCreateSession(
                        start_datetime: dateFormatter.string(from: $0)
                    )
                } ?? []

        // Create a new experience
        loader.show(text: "Creating experience")
        Task {
            do {
                let experience = try await ExperienceCreateRequest(
                    experienceModel: ExperienceCreateModel(
                        category_id: argument!.subcategory.id,
                        language_id: argument!.languageId,
                        description: argument!.description,
                        introductory_video: nil,
                        sessions: sessions,
                        host_info: argument!.hostInfo
                    ))
                    .performRequest()

                guard let experienceId = experience.result.data?.experience_ids.first else {
                    await MainActor.run {
                        loader.dismiss()
                        show(error: "Couldn't get experience id")
                    }
                    return
                }

                var mediaParams = [AddMediasToExperienceMediaRequestParams]()
                var mediaIdx = 1
                for fileWithMetadata in argument.attachedMedias {
                    loader.change(text: "Uploading file \(mediaIdx) of \(argument.attachedMedias.count)")
                    let mimeType = fileWithMetadata.mimeType ?? "application/octet-stream"
                    // Upload only photo
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

                    if mimeType.starts(with: "video"),
                       let thumbData = fileWithMetadata.thumbnail?.jpegData(compressionQuality: 0.9) {
                        // Upload thumbnail
                        let thumbUploadRequest = UploadRequest(
                            data: thumbData,
                            mimeType: "image/jpeg",
                            key: key + ".thumb.jpg"
                        )
                        let thumbKey = thumbUploadRequest.key
                        let thumbUrl = try await thumbUploadRequest.performUpload()
                        mediaParams.append(AddMediasToExperienceMediaRequestParams(
                            file_name: (thumbKey as NSString).lastPathComponent,
                            mime_type: "image/jpeg",
                            url: thumbUrl.absoluteString,
                            key_s3: thumbKey
                        ))
                    }

                    print("Uploaded media \(mediaIdx)")
                    mediaIdx += 1
                }

                _ = try await AddMediasToExperienceRequest(
                    experienceId: experienceId,
                    medias: mediaParams
                ).performRequest()

                await MainActor.run {
                    loader.dismiss()
                    navigator.navigate(to: HostAdInProgressScreen.self)
                }
            } catch {
                await loader.dismiss()
                await show(error: error.localizedDescription)
            }
        }
    }

    override func input(_ argument: HostCalendarArguments) {
        loadViewIfNeeded()

        self.argument = argument

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var experience = ExperienceIndexResponseResult(
            id: -1,
            name: argument.subcategory.name,
            user_id: -1,
            language_id: argument.languageId,
            category_id: argument.subcategory.id
        )

        if argument.subcategory.isVideoOnly {
            experience.duration = 0
            experience.price = 0
        } else {
            experience.duration = argument.category.duration
            experience.price = argument.category.price
        }
        experience.description = argument.description
        experience.sessions = argument
                .generateSessionDates()
                .map {
                    SessionResponseResult(
                        id: -1,
                        start_datetime: dateFormatter.string(from: $0),
                        duration: argument.category.duration,
                        end_datetime: dateFormatter.string(from: $0.addingTimeInterval(TimeInterval(argument.category.duration * 60)))
                    )
                }

        layout.showExperiencePreview(experience: experience, thumb: argument.attachedMedias.first?.thumbnail)
    }
}

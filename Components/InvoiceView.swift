import UIKit
import SnapKit

protocol InvoiceViewDelegate: AnyObject {
    func joinMeeting(reservation: ReservationIndexResponseResult)
    func cancelMeeting(reservation: ReservationIndexResponseResult)
}

class InvoiceView: UIView {
    weak var delegate: InvoiceViewDelegate?

    lazy var backgroundImage = Image(asset: .invoiceBackground)

    lazy var titleLabel = Label(style: .groupTitle, text: "INVOICE", color: .white, lines: 1)

    lazy var dashedLine1 = DashedLine(width: 250, distance: NSNumber(value: 20), color: .white)

    lazy var serviceIcon: Image = {
        let image = Image(asset: .iconMorningCheckIn, tint: Color.main)
        image.contentMode = .scaleAspectFill
        return image
    }()

    lazy var serviceIconView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true

        view.addWithConstraints(view: serviceIcon) {
            $0.center.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }

        view.snp.makeConstraints {
            $0.width.equalTo(56)
            $0.height.equalTo(56)
        }
        return view
    }()

    lazy var serviceNameLabel = Label(style: .invoiceServiceName, text: "MORNING CHECK-IN", color: .white, lines: 1)

    lazy var nameLabel = Label(style: .invoiceName, text: "JOHN DOE", color: .white, lines: 1)

    lazy var dateTimeLabel = Label(style: .invoiceDate, text: "08 APRIL  9:00am - 10:00Am", color: .white, lines: 1)

    lazy var priceLabel = Label(style: .invoicePrice, text: "$6", color: .white, lines: 1)

    lazy var dashedLine2 = DashedLine(width: 250, distance: NSNumber(value: 20), color: .white)

    lazy var joinButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Color.main
        button.layer.cornerRadius = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.setTitle("JOIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Font.light[12]
        button.isHidden = false
        return button
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Color.main
        button.layer.cornerRadius = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Font.light[12]
        button.isHidden = false
        return button
    }()

    private var joinButtonXConstraint: ConstraintMakerEditable!
    private var cancelButtonXConstraint: ConstraintMakerEditable!

    init(reservation: ReservationIndexResponseResult?,
         experience: ExperienceIndexResponseResult?,
         session: SessionResponseResult?,
         allowActions: Bool, delegate: InvoiceViewDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()

        set(reservation: reservation, experience: experience, session: session, allowActions: allowActions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: backgroundImage) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        addWithConstraints(view: titleLabel) {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: dashedLine1) {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(250)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        addWithConstraints(view: serviceIconView) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: serviceNameLabel) {
            $0.top.equalTo(serviceIconView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: nameLabel) {
            $0.top.equalTo(serviceNameLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: dateTimeLabel) {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: priceLabel) {
            $0.top.equalTo(dateTimeLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: dashedLine2) {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(250)
            $0.top.equalTo(priceLabel.snp.bottom).offset(8)
        }

        joinButton.addTarget(self, action: #selector(join), for: .touchUpInside)
        addWithConstraints(view: joinButton) {
            $0.width.equalTo(85)
            $0.height.equalTo(22)
            joinButtonXConstraint = $0.centerX.equalToSuperview().offset(-44)
            $0.bottom.equalToSuperview()
        }

        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        addWithConstraints(view: cancelButton) {
            $0.width.equalTo(85)
            $0.height.equalTo(22)
            cancelButtonXConstraint = $0.centerX.equalToSuperview().offset(44)
            $0.bottom.equalToSuperview()
        }
    }

    private var reservation: ReservationIndexResponseResult?
    private var experience: ExperienceIndexResponseResult?
    private var session: SessionResponseResult?

    func set(reservation: ReservationIndexResponseResult?,
             experience: ExperienceIndexResponseResult?,
             session: SessionResponseResult?,
             allowActions: Bool) {
        self.reservation = reservation
        self.experience = experience
        self.session = session

        if let subCategoryId = experience?.category_id,
           let subCategory = Cat.findSubcategory(id: subCategoryId) {
            serviceIcon.image = subCategory.icon.base64Image
        } else {
            serviceIcon.image = nil
        }

        serviceNameLabel.text = experience?.host ?? ""
        nameLabel.text = experience?.name ?? ""

        if let startTime = session?.getStartDateTime(),
           let endTime = session?.getEndDateTime() {
            let startDF = DateFormatter()
            startDF.dateFormat = "dd MMMM h:mma"
            let endDF = DateFormatter()
            endDF.dateFormat = "h:mma"
            dateTimeLabel.text = "\(startDF.string(from: startTime)) - \(endDF.string(from: endTime))"
        } else {
            dateTimeLabel.text = nil
        }

        if let price = experience?.price {
            priceLabel.text = String(format: "$%.02f", price)
        } else {
            priceLabel.text = ""
        }

        joinButton.isHidden = !allowActions || (reservation?.google_meet_link ?? "").isEmpty
        cancelButton.isHidden = !allowActions

        if !joinButton.isHidden,
           !cancelButton.isHidden {
            // Both buttons are visible
            joinButtonXConstraint.constraint.update(offset: -44)
            cancelButtonXConstraint.constraint.update(offset: 44)
        } else if joinButton.isHidden,
                  !cancelButton.isHidden {
            // Only cancel button is visible
            cancelButtonXConstraint.constraint.update(offset: 0)
        } else if !joinButton.isHidden,
                  cancelButton.isHidden {
            // Only join button is visible
            joinButtonXConstraint.constraint.update(offset: 0)
        }
    }

    @objc func join() {
        guard let reservation = reservation else { return }
        delegate?.joinMeeting(reservation: reservation)
    }

    @objc func cancel() {
        guard let reservation = reservation else { return }
        delegate?.cancelMeeting(reservation: reservation)
    }
}

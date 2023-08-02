import Foundation

struct UserUpdateBankRequestParams: Encodable {
    var bank_account: String
    var bank_account_id: String
}

class UserUpdateBankRequest: BaseRequest<UserUpdateBankRequestParams, UserUpdateBankResponse> {
    init(bankAccount: String, bankAccountId: String) {
        super.init(
            params: UserUpdateBankRequestParams(
                bank_account: bankAccount,
                bank_account_id: bankAccountId
            )
        )
    }

    override var route: OdooRoute {
        .userUpdateBank
    }
}

struct UserUpdateBankResponseResult: Decodable {
    var status: Bool
    var message: String
}

class UserUpdateBankResponse: BaseDataResponse<[UserUpdateBankResponseResult]> {
}

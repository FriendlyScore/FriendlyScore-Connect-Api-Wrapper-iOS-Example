//
//  ViewController.swift
//  FriendlyScoreConnectApiDemo-iOS
//
//  Created by Deepak on 05/07/2021.
//

import UIKit
import FriendlyScoreConnectApi


class ViewController: UIViewController {
    
    
    @IBOutlet weak var createUser: UIButton!
    @IBOutlet weak var fetchBankList: UIButton!
    @IBOutlet weak var fetchConsentScreen: UIButton!
    @IBOutlet weak var fetchBankFlowUrl: UIButton!
    var fsClient: FriendlyScoreClient?=nil
    var  userToken: String?=nil
    var bankList: Array<UserBank>?
    
    
    func  get_access_token_from_your_server() -> String {

          /**
           *
           * Your server must use client_id and client_secret to authorize itself with the FriendlyScore Servers.
           *
           * The successful completion of authorization request will provide you with access_token.
           * This access_token is required to generate a user_token to make user related requests.
           * Your app must ask the server for the `access_token`
           */

        let access_token: String = "get_access_token_from_your_server"

        return access_token
      }
    override func viewDidLoad() {
        super.viewDidLoad()
        createUser.addTarget(self, action: #selector(createUserTokenAction(sender:)), for: .touchUpInside)
        fetchBankList.addTarget(self, action: #selector(fetchBankListAction(sender:)), for: .touchUpInside)
        fetchConsentScreen.addTarget(self, action: #selector(fetchConsentScreenInformationAction(sender:)), for: .touchUpInside)
        fetchBankFlowUrl.addTarget(self, action: #selector(fetchBankFlowUrlAction(sender:)), for: .touchUpInside)

        fsClient = FriendlyScoreClient(environment: Environment.production, clientId: "YOUR_CLIENT_ID", accessToken: get_access_token_from_your_server())
        // Do any additional setup after loading the view.
    }

    @objc private func createUserTokenAction(sender: UIButton) {

        fsClient?.createUserAuthToken(userReference: "user_reference", requestSuccess: { userToken in
            self.userToken = userToken.getToken()
                    print(userToken.getToken())
                }, requestFailure: { failureResponse in
                    let statusCode: Int = failureResponse.statusCode
                    let responseData: Data = failureResponse.data
                    print(statusCode)
                    print(responseData)
                }, otherError: { error in
                    print(error.debugDescription)
                } )
    }
    
    @objc private func fetchBankListAction(sender: UIButton) {

        fsClient?.fetchBankList(userToken: self.userToken!, requestSuccess: { bankList in
                    self.bankList = bankList
                    //Showing the important variables for the first bank
                    var selectedBank: UserBank = self.bankList![0]
                    //Slug of the bank. Will be required for other end points
                    var bankSlug: String = selectedBank.bank.slug
                    //If the user has connected accounts from this bank
                    var connected: Bool? = selectedBank.connected!
                    //The flag when true indicates the bank APIs are available
                    var isActive: Bool? = selectedBank.bank.is_active
                    //Url for the logo of the selected bank
                    var bankLogoUrl: URL? = selectedBank.bank.logo
                    //Max number of months in the past to access data
                    var maxMonthsInPast: Int = (selectedBank.bank.bank_configuration?.transactions_consent_from!)!
                    //Max number of months in the future to access data
                    var maxMonthsInFuture: Int = (selectedBank.bank.bank_configuration?.transactions_consent_to!)!
                    //Accounts for the user, if the user has connected the account
                    var  bankAccountList: Array<BankAccount> = bankList[0].accounts;
            
                    print("Number of banks:", self.bankList!.count)
                }, requestFailure: { failureResponse in
                    
                    let statusCode: Int = failureResponse.statusCode
                    let responseData: Data = failureResponse.data


                }, otherError: { error in
                    print(error.debugDescription)
                })
    }
    
    @objc private func fetchConsentScreenInformationAction(sender: UIButton) {
        var dateFrom: Int64? = nil
        var dateTo: Int64? = nil
        var selectedBank: UserBank = self.bankList![0]
        
        fsClient?.fetchConsentScreenInformation(userToken: self.userToken!, slug: selectedBank.bank.slug, transactionFromTimeStampInSec: dateFrom, transactionToTimeStampInSec: dateTo, requestSuccess: { consentScreenInfo in
            print(consentScreenInfo.metadata?.terms_and_condition_url)
            print(consentScreenInfo.consents)
                }, requestFailure: { failureResponse in
                    let statusCode: Int = failureResponse.statusCode
                    let responseData: Data = failureResponse.data


                }, otherError: { error in
                    print(error.debugDescription)
                })
    }
    
    @objc private func fetchBankFlowUrlAction(sender: UIButton) {
        var dateFrom: Int64? = nil
        var dateTo: Int64? = nil
        var selectedBank: UserBank = self.bankList![0]
        fsClient?.fetchBankFlowUrl(userToken: self.userToken!, slug: selectedBank.bank.slug, transactionFromTimeStampInSec: dateFrom, transactionToTimeStampInSec: dateTo, requestSuccess: { bankFlowUrl in
                    print( bankFlowUrl.url)
                }, requestFailure: { failureResponse in
                    let statusCode: Int = failureResponse.statusCode
                    let responseData: Data = failureResponse.data


                }, otherError: { error in
                    print(error.debugDescription)
                })
    }
    
}




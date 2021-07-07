### Introduction

FriendlyScore Connect API Wrapper allows you build custom UX to connect bank accounts by using FriendlyScore REST API.

### Requirements

- Xcode 10 or greater
- iOS 12.3 or greater
- [FriendlyScore Client Id & Secret](https://friendlyscore.com/company/keys). **DO NOT put your `Client Secret`** in your mobile app.

### Quickstart Demo App

Clone and run the demo project from our [GitHub repository](https://github.com/FriendlyScore/FriendlyScore-Connect-Api-Wrapper-iOS-Example).

### Integrating with FriendlyScore

You can select which environment you want to use the FriendlyScore SDK

  | Environment |   Description |
  | :----       | :--             |
  | sandbox     | Use this environment to test your integration |
  | production  | Production API environment |

These environments are listed in the SDK as below

    Environment.sandbox
    Environment.production

Choose the correct [FriendlyScore Client Id & Secret ](https://friendlyscore.com/company/keys) based on the environment you are using.

### Installation

FriendlyScore Connect is a framework distributed using [CocoaPods](https://cocoapods.org/) dependency manager. If you are not familiar with this concept, please follow [detailed instructions here](https://guides.cocoapods.org/using/getting-started.html).

To integrate, add `FriendlyScoreConnectApi` to your `Podfile`

```bash
pod 'FriendlyScoreConnectApi', '~> 0.1.0'
```

then run following command in your project main directory:
```bash
pod install
```
CocoaPods will install and embed all sources and dependencies into your app.

#### **Steps**

1. Get access token

    
    Your server must use `client_id` and `client_secret` to authorize itself with the FriendlyScore Servers.

    The successful completion of authorization request will provide you with access_token.

    This access_token is required to generate a userToken to make user related requests.

    Your app must ask your server for the `access_token`

    `DO NOT` put your `client_secret` in your mobile app.
    
&nbsp;
&nbsp;

2. Create the `FriendlyScoreClient`

    Choose the `client_id` and the environment you want to integrate. You can access the `client_id` from the FriendlyScore panel

        
        var  environment: Environment = Environment.sandbox
        var client_id: String = "YOUR_CLIENT_ID"
        var access_token: String = "access_token_from_step_1"

        var fsClient: FriendlyScoreClient  = FriendlyScoreClient(environment: environment, clientId: client_id, accessToken: access_token)
     

    The `fsClient` will be required to make other requests 

&nbsp;
&nbsp;

3. Create User Token

    You must create `userToken` in order to make any request for the user.

    In order to receive response you must implement closures `requestSuccess`, `requestFailure`, `otherError`.
    
    `requestSuccess` - if the status code is between [200,300). Response type `UserToken`

    `requestFailure` - if there was request failure, (status code = 401, 403, 500 etc..). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`

    &nbsp;
    &nbsp;
    #### **Required parameters:** 
    `fsClient` - FriendlyScoreClient

    `user_reference` - Unique user reference that identifies user in your systems.

    
        
        var userReference: String = "user_reference"
        
        fsClient?.createUserAuthToken(userReference: userReference, 
            requestSuccess: { userToken in
                self.userToken = userToken.getToken()
            }, 
            requestFailure: { moyaResponse in
                let statusCode = moyaResponse.statusCode
                let data: Data = moyaResponse.data                 
            }, 
            otherError: { error in
                print(error.debugDescription)
            } 
        )
    Use the `fsClient` to make the requests

    
&nbsp;
&nbsp;

4. Get List of Banks

    You can obtain the list of banks for the user

    In order to receive response you must implement closures `requestSuccess`, `requestFailure`, `otherError`.
    
    `requestSuccess` - if the status code is between [200,300). Response type `Array<UserBank>?`

    `requestFailure` - if there was request failure, (status code = 401, 403, 500 etc..). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`

    &nbsp;
    &nbsp;
    #### **Required parameters:** 

    `fsClient` - FriendlyScoreClient

    `userToken` - User Token obtained from authorization endpoint

        var userToken: String = "User Token obtained from authorization endpoint"

        fsClient?.fetchBankList(userToken: userToken, 
                requestSuccess: { bankList in
                    
                }, 
                requestFailure: { moyaresponse in
                    let statusCode = moyaResponse.statusCode
                    let data: Data = moyaResponse.data  

                }, 
                otherError: { error in
                    print(error.debugDescription)
                }
        )
    

    The important values for each bank that will be required for the ui and future requests. For example, for the first bank in the list, we show the important values:

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
    
    The `bankSlug` value in the code block above is used across all the endpoints to build the rest of the user journey.

    The `maxMonthsInPast` and  `maxMonthsInFuture` variables in the block above are the maximum number of months in past and future for which account information can be accessed. You must use these values to calculate timestamps for future

&nbsp;
&nbsp;

5. Get Bank Consent Screen Information

    Once the user has selected a bank from the list. You must show the user the necessary information as required by the law.

    In order to receive response you must implement closures `requestSuccess`, `requestFailure`, `otherError`.
    
    `requestSuccess` - if the status code is between [200,300). Response type `ConsentScreenInformation`

    `requestFailure` - if there was request failure, (status code = 401, 403, 500 etc..). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`

    Make this request to create the consent screen using the required and regulated information for the bank the user selected

    &nbsp;
    &nbsp;
    #### **Required parameters:** 


    `fsClient` - FriendlyScoreClient
        
    `userToken` - User Token obtained from authorization endpoint
        
    `bankSlug` - Slug for the bank user has selected from the list of banks
        
    `transactionFromTimeStampInSec` - Time stamp in seconds. Set to null to use default

    `transactionToTimeStampInSec` - Time stamp in seconds. Set to null to use default.
         
    &nbsp;
    &nbsp;
    
        
        fsClient?.fetchConsentScreenInformation(userToken: self.userToken!, slug: selectedBank.bank.slug, transactionFromTimeStampInSec: dateFrom, transactionToTimeStampInSec: dateTo, requestSuccess: { consentScreenInfo in
            print(consentScreenInfo.metadata?.terms_and_condition_url)
            print(consentScreenInfo.consents)
                }, requestFailure: { failureResponse in
                    let statusCode: Int = failureResponse.statusCode
                    let responseData: Data = failureResponse.data


                }, otherError: { error in
                    print(error.debugDescription)
                })

     The `ConsentScreenInformation` includes 2 objects `metadata` and `consents`. You can use information in `metadata` to build your custom consent information text. The `consents` object provides ready-to-use text to build the consent screen.
    
&nbsp;
&nbsp;

6. Get Bank Flow Url
    
    Make this request from the consent screen after the user has seen all the information that will is being requested.
    
    You must make this request to get the url to open the Bank Flow for users to authorize access account information

    In order to receive response you must implement closures `requestSuccess`, `requestFailure`, `otherError`.
    
    `requestSuccess` - if the status code is between [200,300). Response type `BankFlowUrl`

    `requestFailure` - if there was request failure, (status code = 401, 403, 500 etc..). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`
    
    &nbsp;
    &nbsp;
    #### **Required parameters:** 


    `fsClient` - FriendlyScoreClient
        
    `userToken` - User Token obtained from authorization endpoint
        
    `bankSlug` - Slug for the bank user has selected from the list of banks
                
    `transactionFromTimeStampInSec` - Time stamp in seconds. Use the same value as used in the Consent screen endpoint. Set to null to use default

    `transactionToTimeStampInSec` - Time stamp in seconds. Use the same value as used in the Consent screen endpoint. Set to null to use default.
         
    &nbsp;
    &nbsp;
    

        fsClient?.fetchBankFlowUrl(userToken: userToken, slug: bankSlug, transactionFromTimeStampInSec: dateFrom, transactionToTimeStampInSec: dateTo, requestSuccess: { bankFlowUrl in
                    print( bankFlowUrl.url)
                }, requestFailure: { failureResponse in
                    let statusCode: Int = failureResponse.statusCode
                    let responseData: Data = failureResponse.data


                }, otherError: { error in
                    print(error.debugDescription)
                })
    


    From `BankFlowUrl` extract the `url` value and trigger it to start the authorization process with the bank


&nbsp;
&nbsp;


7. Redirect back to the app

    The user is redirected back to your app after a user successfully authorizes, cancels the authorization process or any other error during the authorization.

    &nbsp;
    &nbsp;

    Your app must handle redirection for

    &nbsp;
    &nbsp;

    `/openbanking/code` - successful authorization by user. It should have parameters `bank_slug`

    &nbsp;
    &nbsp;

    `/openbanking/error` - error in authorization or user did not complete authorization. It should have 2 parameters. `bank_slug` and `error` 


    In order to handle redirection properly, listen to url in the function `application(_:open:options:)`:

    ```swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
            //Extract url parameters
            return true
    }
    ```
    ### Adding URL Types
    Go to the [Redirects](https://friendlyscore.com/company/redirects) section of the FriendlyScore developer console and provide your `Bundle Identifier`.


    Navigate to your app target, create new URL Types object and add your bundle identifier to `Identifier` and `URL Schemes` field, as below:

    <p align="center">
    <img width="1000" src="https://dpcnl9aeuvod8.cloudfront.net/docs_assets/url_types.png">
    </p>



&nbsp;
&nbsp;

8. Delete Account Consent

    Make this request to allow the user to delete consent to access account information.


    In order to receive response you must implement closures `requestSuccess`, `requestFailure`, `otherError`.
    
    `requestSuccess` - if the status code is between [200,300). Response type `Void`

    `requestFailure` - if the status code is between [300,600). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`

    &nbsp;
    &nbsp;

    #### **Required parameters:** 
    `fsClient` - FriendlyScoreClient

    `userToken` - User Token obtained from authorization endpoint
        
    `bankSlug` - Slug for the bank


        fsClient?.deleteBankConsent(userToken: userToken, slug: bankSlug,
                requestSuccess: { _ in
                    
                }, 
                requestFailure: { moyaresponse in
                    let statusCode = moyaResponse.statusCode
                    let data: Data = moyaResponse.data  

                }, 
                otherError: { error in
                    print(error.debugDescription)
                }
        )

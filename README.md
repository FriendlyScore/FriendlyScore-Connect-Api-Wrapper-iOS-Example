### Introduction

FriendlyScore Connect API Wrapper allows you build custom UX to connect bank accounts by using FriendlyScore REST API.

### Requirements

- Xcode 10 or greater
- iOS 12.3 or greater

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


### Installation

FriendlyScore Connect is a framework distributed using [CocoaPods](https://cocoapods.org/) dependency manager. If you are not familiar with this concept, please follow [detailed instructions here](https://guides.cocoapods.org/using/getting-started.html).

To integrate, add `FriendlyScoreConnectApi` to your `Podfile`

```bash
pod 'FriendlyScoreConnectApi', '~> 0.2.0'
```

then run following command in your project main directory:
```bash
pod install
```
CocoaPods will install and embed all sources and dependencies into your app.

#### **Steps**

1. Get User token

    A user token can be created for the user using the `customer_id`. A `customer_id` is available after creating the user [Create Customer](https://docs.friendlyscore.com/api-reference/customers/create-customer)

    You must then use the `customer_id` to create `user_token` [Create User Token](https://docs.friendlyscore.com/api-reference/customers/create-customer-token)

&nbsp;
&nbsp;

2. Create the `FriendlyScoreClient`
        
        Choose the  the environment you want to integrate.

        var  environment: Environment = Environment.sandbox

        var fsClient: FriendlyScoreClient  = FriendlyScoreClient(environment: environment)
     

    The `fsClient` will be required to make other requests 

&nbsp;
&nbsp;


3. Get List of Banks

    You can obtain the list of banks for the user

    In order to receive response you must implement closures `requestSuccess`, `requestFailure`, `otherError`.
    
    `requestSuccess` - if the status code is between [200,300). Response type `Array<UserBank>?`

    `requestFailure` - if there was request failure, (status code = 401, 403, 500 etc..). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`

    &nbsp;
    &nbsp;
    #### **Required parameters:** 

    `userToken` - User Token obtained from your server

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

        
    `userToken` - User Token obtained from your server
        
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
        
    `userToken` - User Token obtained from your server
        
    `bankSlug` - Slug for the bank user has selected from the list of banks
                
    `transactionFromTimeStampInSec` - Time stamp in seconds. Use the same value as used in the Consent screen endpoint. Set to null to use default

    `transactionToTimeStampInSec` - Time stamp in seconds. Use the same value as used in the Consent screen endpoint. Set to null to use default.

    `redirectUri` - This must be the scheme you are using to bring the user back to your app. It must be the same as set in the FriendlyScore developer console. For details on setting the app for redirection see section 7.

         
    &nbsp;
    &nbsp;


        let redirectUriValue: String = "com.friendlyscore.FriendlyScoreConnectApiDemo-iOS"

        fsClient?.fetchBankFlowUrl(userToken: userToken, slug: bankSlug, transactionFromTimeStampInSec: dateFrom, transactionToTimeStampInSec: dateTo, redirectUri: redirectUriValue, requestSuccess: { bankFlowUrl in
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

    `requestFailure` - if there was request failure, (status code = 401, 403, 500 etc..). Response type `MoyaResponse`

    `otherError` - Any other error such as timeout or unexpected error. Response type `Swift.Error?`

    &nbsp;
    &nbsp;

    #### **Required parameters:** 

    `userToken` - User Token obtained from your server        
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

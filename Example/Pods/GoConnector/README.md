
![Clover](https://camo.githubusercontent.com/6c829b55aa7851e726e5fc0fd70448a0c00427b2/68747470733a2f2f7777772e636c6f7665722e636f6d2f6173736574732f696d616765732f7075626c69632d736974652f70726573732f636c6f7665725f7072696d6172795f677261795f7267622e706e67)

# Clover SDK for iOS POS Integration 
## Version
Version: 3.0.0  
## Overview
This SDK allows your iOS-based Point-of-Sale (POS) system to communicate with a Clover® payment device and process payments. 

It includes the SDK and an example POS. To work with the project effectively, you will need:
* XCode 9.0.1+  
* iOS 9.0 and above on your device  
* Cocoapods 
  
To experience transactions end-to-end from the merchant and customer perspectives, we also recommend ordering a [Clover Go DevKit](http://cloverdevkit.com/collections/devkits/products/clover-all-in-one-developer-kit)
  
The SDK enables your custom mobile point-of-sale (POS) to accept card present, EMV compliant payment transactions. 
Clover Go supports two types of card readers: a magnetic stripe, EMV chip-and-signature card reader (audio jack) and an all-in-one card reader (Bluetooth) that supports Swipe, EMV Dip, and NFC Contactless payments. The SDK is designed to allow merchants to take payments on iOS smartphones and tablets.  

**Core features of the  SDK for Clover Go include:**   
1. Card Present Transactions – Transactions in which the merchant uses the approved card reader to accept physical credit or debit cards on a connected smartphone or tablet. The Clover Go platform supports the following payment options:  
   * **Magnetic Stripe Card** – A traditional payment card that has a magnetic stripe.  
   * **EMV Card** – A payment card containing a computer chip that enhances data security. Clover Go's EMV compliant platform enables the customer or merchant to insert an EMV card into the card reader.  
   * **NFC Contactless Payment** – A transaction in which a customer leverages an Apple Pay, Samsung Pay, or Android Pay mobile wallets by tapping their mobile device to the card reader.   

**The Clover Go SDK currently supports the following payment transactions:**   
* **Sale** - A transaction used to authorize and capture the payment amount in at the same time. A Sale transaction is final and the amount cannot be adjusted. 
* **Auth** - A transaction that can be tip-adjusted until it is finalized during a batch closeout. This is a standard model for a restaurant that adjusts the amount to include a tip after a card is charged.  
* **Void** - A transaction that cancels or fully reverses a payment transaction. 
* **Refund** - A transaction that credits funds to the account holder.  
* **PreAuth** - A pre-authorization for a certain amount. 
* **PreAuth Capture** - A Pre-Auth that has been finalized in order to complete a payment (i.e., a bar tab that has been closed out).   
* **Partial Auth** - A partial authorization. The payment gateway may return a partial authorization if the transaction amount exceeds the customer’s credit or debit card limit.  
* **Tip Adjust** - A transaction in which a merchant takes or edits a tip after the customer’s card has been processed (i.e., after the initial Auth transaction).

## Getting Started
This section will provide some quick steps to get started with the SDK. To integrate with Clover Go devices you will need initialize the CloverGoDeviceConfiguration object with the right initialization values and that includes the accesstoken that you retreive by going through the OAuth flow. You will need to follow these initial steps

### Initial Setup  
**1. Create Developer Account:** Go to the Clover sandbox developer portal at https://sandbox.dev.clover.com/developers/ and create a developer account.  
![developer_account](/images/developer-account.png)  
**2. Create a new application:** Log into developer portal and create a new app - enter app name, unique package name, and check all the clover permissions your application will require to function properly.  
![create_app](/images/app_create.png)  
**3. Application Settings/Credentials:** Once your application is created you can note down the App ID and Secret which will be required in your code for OAuth flow.  
![appid_secret](/images/appid_secret.png)  
**4.Provide re-direct URL for your OAuth flow:** Enter the redirect URL where Clover should redirect the authorization response to in the site URL field in the Web Configuration settings. The default OAuth response should be "Code".  
![app_redirect](/images/app_redirect.png)  
**Note:** The developer portal does not currently accept non-http(s) URL schemes. If you have a custom URL scheme for native iOS and Android applications (such as myPaymentApp://clovergoauthresponse), send an email to Clovergo-Integrations@firstdata.com with your App ID and redirect URL request.  
  
**5. Set app permissions:** Your application will require Clover permissions to work correctly. Set your permissions by going to Settings, then Required Permissions menu.    
![app_permissions](/images/app_permissions.png) 
  
**6. Setup your unique application id:** Provide a unique application id for your application, you can use your package name or any identifier that uniquely identifies the transactions of your application. Set this up in the Semi-integrated App section of your application settings.  
![app_remoteid](/images/app_remoteid.png)  
  
Please make sure that your application bundle id is the same as the one defined in this field.
  
### OAuth Flow  
This section describes the OAuth flow steps to get the access token required to initialize the CloverGoDeviceConfiguration object.  

![oauth_flow](/images/oauth_flow.png)  
**Step 1.** Invoke the Clover Authorize URL from your pos application using the App ID of your application (Step #3 above). This action will prompt the user to log into clover merchant account, once successfuly logged in they will need to approve the app for the first inital login. Authorize URL for Sandbox Environment: https://sandbox.dev.clover.com/oauth/authorize?client_id={app_id}&response_type=code  
**Step 2.** The user will be redirected to the redirect URL set in step 4 above.    
**Step 3.** Parse the URI data to get the Merchant ID, Employee ID, Client ID and Code.  
**Step 4.** Make a REST call that includes the Client ID (it's the app id), secret, and Code from your backend server to get the access token. https://sandbox.dev.clover.com/oauth/token?client_id={appId}&client_secret={appSecret}&code={codeUrlParam}  
**Note** Please note that the sample application as part of this project provides a hosted service for Step 4. Use your own such service to execute this step.  
**Step 5.** Parse the response of step 4 and retrieve the access token. The access token provides the Merchant and Employee context to the SDK, all transactions processed will be under this context.  
  
  
## Developer XCode iOS Project Setup
```
add pod 'GoConnector', '3.0.0' in your PODFILE in target
For example -
platform :ios, '9.0'
use_frameworks!
target 'CloverConnector_Example' do
pod 'GoConnector', '~> 3.0.0'
end
```
### Leveraging SDK within your application
#### 1. In your ```AppDelegate.swift``` file declare the following...
``` import GoConnector
    public var cloverConnector:ICloverGoConnector?
    public var cloverConnectorListener:CloverGoConnectorListener?
```
#### 2. Create ```CloverGoConnectorListener.swift``` inherit from ```ICloverGoConnectorListener```
```
    import GoConnector
    weak var cloverConnector:ICloverGoConnector?

    public init(cloverConnector:ICloverGoConnector){
        self.cloverConnector = cloverConnector;
    }
```
  Below are the methods which will be useful to add in this class
  Implement all ``` CardReaderDelegate ``` methods in here...

* ``` func onDevicesDiscovered(devices: [CLVModels.Device.GoDeviceInfo]) ``` - This delegate method is called when the card reader is detected and selected from the readers list
* ``` func onDeviceReady(merchantInfo: MerchantInfo) ``` - called when the device is ready to communicate
* ``` func  onDeviceConnected () -> Void ``` - called when the device is initially connected
* ``` func  onDeviceDisconnected () -> Void ``` - called when the device is disconnected, or not responding
* ``` func onDeviceError( _ deviceErrorEvent: CloverDeviceErrorEvent ) -> Void ``` – called when there is error connecting to reader

Implement all ``` TransactionDelegate ``` methods in here...
* ``` func onTransactionProgress(event: CLVModels.Payments.GoTransactionEvent) -> Void ``` - called when there is any event with the card reader after the transaction is started

Parameter event: Gives the details about the CardReaderEvent during the transaction
```
switch event
        {
        case .EMV_CARD_INSERTED,.CARD_SWIPED,.CARD_TAPPED:
            break
        case .EMV_CARD_REMOVED:
            break
        case .EMV_CARD_DIP_FAILED:
            break
        case .EMV_CARD_SWIPED_ERROR:
            break
        case .EMV_DIP_FAILED_PROCEED_WITH_SWIPE:
            break
        case .SWIPE_FAILED:
            break
        case .CONTACTLESS_FAILED_TRY_AGAIN:
            break
        case .SWIPE_DIP_OR_TAP_CARD:
            break
        default:
            break;
        }
```
* ``` func onSaleResponse(response: SaleResponse)``` – called at the completion of a sale request with either a payment or a cancel state

* ``` func onAuthResponse(response: AuthResponse) ``` – called at the completion of an auth request with either a payment or a cancel state

* sale - collect a final sale payment
* auth - collect a payment that can be tip adjusted

**Note**: Rest of the methods of ``` ICloverConnectorListener ``` class you have to add here but can be left blank like ``` onRetrieveDeviceStatusResponse, onMessageFromActivity, ``` etc.

#### 3. SDK Initialization with 450 Reader

The following parameters are required for SDK initialization
* apiKey - Provided to developers during registration
* secret - Provided to developers during registration
* accessToken - Provided to developers during registration
* allowDuplicateTransaction - set to true for hackathon purpose
* allowAutoConnect - set to true for hackathon purpose
```
func connectToCloverGoReader() {
        let config : CloverGoDeviceConfiguration = CloverGoDeviceConfiguration.Builder(apiKey: "", secret: "", env:   .live).accessToken(accessToken: "").deviceType(deviceType: .RP450).allowDuplicateTransaction(allowDuplicateTransaction: true).allowAutoConnect(allowAutoConnect: true).build()
        
        cloverConnector = CloverGoConnector(config: config)
        
        cloverConnectorListener = CloverGoConnectorListener(cloverConnector: cloverConnector!)
        cloverConnectorListener?.viewController = self.window?.rootViewController
        (cloverConnector as? CloverGoConnector)?.addCloverGoConnectorListener(cloverConnectorListener:         (cloverConnectorListener as? ICloverGoConnectorListener)!)
        cloverConnector!.initializeConnection()   
    }
```

#### 4. Execute a Sale Transaction
Required parameters for sale transaction:
1.	amount – which will be total amount you want to make a transaction
2.	externalId: random unique number for this transaction

Other Optional Parameters can be ignored for the hackathon
```
@IBAction func doSaleTransaction(sender: AnyObject) {
        let totalInInt = Int(totalAmount * 100) --  amount should be in cents
        let saleReq = SaleRequest(amount:totalInInt, externalId:"\(arc4random())") – pass total amount in cents and random external Id
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.sale(saleReq) – make sale request
    }
```

#### 4. Execute a Auth Transaction
Required parameters for auth transaction:
1.	amount – which will be total amount you want to make a transaction
2.	externalId: random unique number for this transaction

Other Optional Parameters can be ignored for the hackathon
``` 
@IBAction func doAuthTransaction(sender: AnyObject) {
        let totalInInt = Int(totalAmount * 100) --  amount should be in cents
        let authReq = AuthRequest(amount:totalInInt, externalId:"\(arc4random())") – pass total amount in cents and random external Id
        (UIApplication.sharedApplication().delegate as! AppDelegate).cloverConnector?.auth(authReq) – make auth request
    }
```
#### 5. Handling Duplicate and AVS Transaction Error

``` public func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) ``` -- called if the device needs confirmation of a payment (duplicate verification)

Example Code to Handle Duplicate Transactions:
If there is a duplicate transaction returned there will be a pop up to user whether to proceed or not (i.e with 2 options “Accept” or “Reject”)
* Accept -  ``` strongSelf.cloverConnector?.acceptPayment(payment) ```
* Reject – ``` strongSelf.cloverConnector?.rejectPayment(payment) ```

``` 
public func onConfirmPaymentRequest(_ request: ConfirmPaymentRequest) {
        if let payment = request.payment,
            let challenges = request.challenges {
            confirmPaymentRequest(payment: payment, challenges: challenges)
        } else {
            showMessage("No payment in request..")
        }
    }  

  func confirmPaymentRequest(payment:CLVModels.Payments.Payment, challenges: [Challenge]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if challenges.count == 0 {
                print("accepting")
                strongSelf.cloverConnector?.acceptPayment(payment)
            } else {
                print("showing verify payment message")
                var challenges = challenges
                let challenge = challenges.removeFirst()
                var alertActions = [UIAlertAction]()
                alertActions.append(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] action in
                    guard let strongSelf = self else { return }
                    strongSelf.confirmPaymentRequest(payment: payment, challenges: challenges)
                }))
                alertActions.append(UIAlertAction(title: "Reject", style: .cancel, handler: { [weak self] action in
                    guard let strongSelf = self else { return }
                    strongSelf.cloverConnector?.rejectPayment(payment, challenge: challenge)
                }))
                strongSelf.showMessageWithOptions(title: "Verify Payment", message: challenge.message ?? "", alertActions: alertActions)
            }
        }
    }
```


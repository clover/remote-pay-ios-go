
![Clover](https://camo.githubusercontent.com/6c829b55aa7851e726e5fc0fd70448a0c00427b2/68747470733a2f2f7777772e636c6f7665722e636f6d2f6173736574732f696d616765732f7075626c69632d736974652f70726573732f636c6f7665725f7072696d6172795f677261795f7267622e706e67)

# Clover SDK for iOS POS Integration 
## Version
Version: 3.2.1  
## Overview
This SDK allows your iOS-based Point-of-Sale (POS) system to communicate with a Clover® payment device and process payments. 

It includes the SDK and an example POS. To work with the project effectively, you will need:
* XCode 11.1
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

# Getting Started

This section will provide both high-level and detailed steps in getting started with the SDK.

## High-Level View of the Integration Process
1. Create a sandbox developer account to test the sample app included with the SDK.

    **Note**: You’ll need to request for a sandbox API key and secret to process transactions with your Go Devkit. You can request these values from the DevRel team via dev@clover.com.

2. Apply the same steps you’ve learned from testing the sample app to test your own app.

   **Note**: You can use the same Sandbox API key and secret from step 1.

3. Once your app is ready to be released to production, your app will need to go through Clover Go’s QA review.
4. When your sandbox app is approved by the Clover Go Q&A team, you will need to create a new prod developer account and register your application.
5. Your prod account and prod app then goes through the Clover Go App Approval process. This is a relatively quick process where the DevRel team does the following:

   - Reviews and verifies the information submitted for your developer profile.
   - Ensures that your app’s Requested Permissions do not include Customer Read, Write permissions and Employee Write permissions, but includes everything else.
   - Ensures that your app is not published.

6. Once you have successfully completed the Clover Go App Approval process, you can now request for a production API key and secret from the DevRel team to make live transactions!


## Tips on Integrating with the Sample App

### Initial Setup
1. **Create Developer Account**: [Go to the Clover sandbox developer portal](https://sandbox.dev.clover.com/developers/) and create a developer account.
![1](/images/1.png)

2. **Create a new application**: Log into your developer portal and create a new app.
![2](/images/2.png)
![2a](/images/2a.png)

### OAuth Flow
To integrate with Clover Go devices, you will need to initialize the `CloverGoDeviceConfiguration` object with the right initialization values. This includes the **access token** that you retrieve by going through the OAuth flow. Below is a guide through the OAuth flow.

The access token is generated for a specific merchant employee in order to provide user context for a given payment transaction.

1. Go to your **App**’s **Settings** on the [Sandbox Dev Dashboard](https://sandbox.dev.clover.com/developers/). Make sure to save your **App ID** and **App Secret** somewhere; you’ll need them for later.
![oauth1](/images/oauth1.png)

2. Change the App Type to be REST Clients > **Web**.
![oauth2](/images/oauth2.png)

3. Make sure that your app has *disabled* Customer Read/Write, Employees Write and enabled the rest of the Permissions in **App Settings** > **Requested Permissions**.
![oauth3](/images/oauth3.png)

   **Warning**: Failure to set these permissions accordingly will lead to an invalid access token, which will prevent the Clover Go SDK from being initialized.

4. Edit your app’s REST Configuration. The Site URL should be your app’s URL. But if you don’t have one set up yet, you can just use `https://sandbox.dev.clover.com` for now. Make sure the Default OAuth Response is **CODE**.
![oauth4](/images/oauth4.png)

   **Note**: The developer portal does not currently accept non-http(s) URL schemes. If you have a custom URL scheme for native iOS and Android applications (such as myPaymentApp://clovergoauthresponse), send an email to `Clovergo-Integrations@firstdata.com` with your App ID and redirect URL request.

5. Click the **Market Listing** tab and then on **Preview in App Market**.
![oauth5a](/images/oauth5a.png)

   **Preview In App Market** opens the app preview page as your test merchant:
![oauth5b](/images/oauth5b.png)

6. If the app is not installed for your test merchant, click **Connect** and then **Accept** to install the app. If the app is installed, click **Open App**. Either of these steps will open a browser tab with a URL containing a **CODE** parameter: 

   `https://sandbox.dev.clover.com/?merchant_id={MERCHANT_ID}1&employee_id={EMPLOYEE_ID}&client_id={CLIENT_ID}&code={CODE}`
![oauth6](/images/oauth6.png)

   Save the **CODE** value somewhere.

7. Pass in the **App ID**, **App Secret**, and **CODE** you saved earlier into the following URL: 

   `https://sandbox.dev.clover.com/oauth/token?client_id={APP_ID}&client_secret={APP_SECRET}&code={CODE}`

   (do not include the curly braces).

8. Visit that URL in your browser, and you should be provided with your access token 🎉. 

   **Note**: If you get an “Unknown Client ID” message, check that you don’t include any spaces in the URL and visit the URL again.

### Running the Sample App

#### Prerequisites
1. Clone the SDK, go into the Example folder and check out the branch for Swift 5:

       git clone https://github.com/clover/remote-pay-ios-go.git
       cd remote-pay-ios-go/Example
       git checkout CloverGo_Swift5.0
2. Ensure that the following dependencies in your `Podfile` are set to the right versions:

       pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :tag => '3.0.5'pod 'GoConnector', '3.3.5'

3. Update your project dependencies by running `pod install`.

#### Xcode Steps
1. Close any current Xcode sessions and open `CloverConnector.xcworkspace`.
2. Set your `Enable Bitcode` setting to **false** for following:

   -- **Project Target** (CloverConnector > CloverConnector_Example > Build Options > Enable Bitcode = No)

   -- **Pod CloverGoSDK** (Pods > CloverGoSDK > Build Settings > Build Options > Enable Bitcode = No)
   ![xcode](/images/xcode.png)

   -- **Pod GoConnector** (Pods > GoConnector > Build Settings > Build Options > Enable Bitcode = No)
3. In `ViewController.swift`, set your **accessToken**, **apiKey**, and **secret** in the following code block:

```
   override func viewDidLoad() {
        super.viewDidLoad()
        PARAMETERS.accessToken = "Access token that you generated via the OAuth flow earlier"
        PARAMETERS.apiKey = "Get this value from your DevRel representative"
        PARAMETERS.secret = "Get this value from your DevRel representative"
        if let savedEndpoint = UserDefaults.standard.string(forKey: WS_ENDPOINT) {
            endpointTextField.text = savedEndpoint
        }
    }
```

### FAQ
- **How do I generate an OAuth token in prod?**

   Follow the same steps that were taken to generate the OAuth token for the sandbox environment but now use `clover.com`. More info [here](https://docs.clover.com/clover-platform/docs/using-oauth-20).
- **I want to publish my Clover Go Android/iOS app to Clover's App Market!**

   Clover Go developers cannot publish their app to Clover’s App Market because it will not work for any merchant as the app is not meant to be installed on Clover devices like Mini and Flex. The only exception is if your app’s type is strictly for the web. In all other cases, you will need to create a separate app and go through a different [App Approval process](https://docs.clover.com/clover-platform/docs/clover-app-approval-process) to get the app reviewed.
- **I’m getting an invalid credentials response.**

   Please consult with your DevRel representative to make sure that your API key and secret tokens are correct. If they are, please try uninstalling and reinstalling your app from your test merchant.
- **I have the correct API key and secret but I still can’t connect to the reader.**

   Please make sure that your Clover Go reader is on and that your Android or Apple device has bluetooth on.
- **I’ve tried everything and my app is still running into issues when attempting a transaction in Prod.**

   Please check if you are using a Production reader by ensuring that there is no "Development" text on your device. A sandbox reader will have the word "Development" on the device, while a production reader will not.
   
   If you have the correct reader, please make sure your app has disabled Customer R/W, Employees W and enabled the rest of the Permissions. Btw, if you've recently changed your app’s Permissions settings, you will need to uninstall and reinstall the app, and re-generate the access token. This is because earlier tokens you have will only work for older requested permissions.

   If our suggestions above do not work, we strongly encourage you to use your sandbox API key and secret to experiment with our sample app, to ensure that you understand how to accomplish certain implementations.

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


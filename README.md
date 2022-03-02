# LoyaltyApp iOS starter


## Installation 🚀
To create new app using starter follow instructions in [Designer repository](https://bitbucket.org/boost-development/designer).

## General

* Use only SSH
* Gemfile - All external dependencies should be tagged (if possible)

## Schemes

#### Debug
For internal (developer) testing purposes. Optimization **OFF**, staging
#### Staging
For external (QA) testing purposes. Optimization **OFF**, staging
#### DebugProduction
For internal (developer) testing purposes. Optimization **OFF**, production
#### Release
For deployment. Optimization **ON**, production

## Deploy checklist
* BundleID
* Crashlytics
	* Make sure you have installed Fabric macOS app
	* Build application with Fabric app open
	* Fabric TeamID: `3869f751d62404093f5afabd4eb963c4b778dc92 d7f6b9e6739ca3deda043ae65fd5e92b5477e99a238567e0a30f12ebf339bccc`
* Mixpanel token and use `Trackers.injectMixpanelData()` (if needed)
* FacebookID
* T&C - replace in `TermsAndConditions.txt`
* Credentials
	* Articles/Events/Shops - contact Product Owner
	* TBP - [production](https://loyalty.boostcom.no/), [staging](https://loyalty.dev.boostcom.no/)
	* DMP - [production](https://insight.boost.no), [staging](https://insight.dev.boost.no)
	* Coupons - contact Product Owner
* Deep links
	* Configure - [production](https://al.bstcm.no/admin), [staging](https://al.dev.bstcm.no/admin)
	* Add correct slug in `archived-expanded-entitlements.xcent`
* Push notifications
	* Generate certificates for both production and development using:
	```
	fastlane pem --development
	```
	and:
	```
	fastlane pem
	```
	* Move created certificates to `Utilities/Certificates`
	* Upload certificates to firebase
* Homepage URL
* Replace loco api key in `Utilities/loco.sh`
## Application icon
To create badge on staging app icon run:
`./Utilities/badge.sh`

## After release
We use BITCODE, so dSYMs should be uploaded do Fabric after deployment to iTunes Connect.
Use our [dSYM Uploader](https://bitbucket.org/boost-development/dsym_uploader).
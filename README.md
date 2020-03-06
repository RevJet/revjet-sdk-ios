# RevJet iOS SDK

### Available macros

* Bundle ID: ```{bundleid}```
* Bundle Version: ```{bundlever}```
* Connection Type: ```{contype}```
* DNT Flag: ```{dnt}```
* Device Language: ```{language}```
* Device Model: ```{device}```
* Device Type: ```{dtype}```
* Area Code: ```{areacode}```
* City Name: ```{city}```
* Country: ```{country}```
* Latitude: ```{lat}```
* Longitude: ```{long}```
* Metro Code: ```{metro}```
* Region: ```{region}```
* Zip Code: ```{zip}```
* IDFA: ```{_ifa}```
* API Frameworks: ```{_mraid}```
* Video Ad Type format: ```{_video_type}```
* Linearity: ```{_video_linearity}```
* MIME Types: ```{_video_mime_types}```
* Min Duration: ```{_video_mindur}```
* OS Name: ```{osname}```
* OS Version: ```{osver}```
* Site Name: ```{appname}```
* User Gender: ```{gender}```
* User locale: ```{locale}```

### Available SDK parameters
_(SDK parameters are defined in ```<meta>``` tags.)_

1. ```<meta name="Parameter-AdType" content="Banner">```

   Ad Type. "Banner" or "Interstitial". Default: "Banner".

* ```<meta name="Parameter-NetworkType" content="RJ">```

  Adapter/Network type. "RJ" or "MRAID". Default: "RJ".

* ```<meta name="Parameter-WIDTH" content="320">```

  The width of the banner. Can be omitted.

* ```<meta name="Parameter-HEIGHT" content="64">```

  The height of the banner. Can be omitted.

## Supported ad sizes

* 320x50
* 320x64
* 1024x768
* 768x1024
* 728x90
* 480x320
* 320x480
* 300x250

To support additional ad sizes you need to update ```+ (CGSize)supportedSizeForSize:(CGSize)aSize``` method in
"RevJetSDK/Utilities/RJUtilities.m".
 
## Overriding LP URL handling

By default, any LP URLs will be opened in the external browser.
It is possible to override this behaviour by implementing ```- (BOOL)shouldOpenURL:(NSURL*)url``` function (from ```RJSlotDelegate```):
```
- (BOOL)shouldOpenURL:(NSURL*)url
{
    // Here we test “url” to some value ...
 
    // Return YES to open in the external browser
    // Return NO to cancel opening the url in the external browser (here we can show something in-app)
    return YES; 
}
```



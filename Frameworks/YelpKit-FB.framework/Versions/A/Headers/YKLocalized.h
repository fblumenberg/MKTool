//
//  YKLocalized.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 11/18/08.
//  Copyright 2008 Yelp. All rights reserved.
//

// Patches localization call.
#undef NSLocalizedStringFromTableInBundle
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
[bundle yelp_localizedStringForKey:(key) value:nil tableName:(tbl)]

#undef NSLocalizedStringWithDefaultValue
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
[bundle yelp_localizedStringForKey:(key) value:val tableName:(tbl)]

#undef NSLocalizedStringForLocale
#define NSLocalizedStringForLocale(key, tbl, bundle, locale) \
[bundle yelp_localizedStringForKey:(key) tableName:(tbl) locale:(locale)]

// Use instead of NSLocalizedString
#ifdef YKLocalizedString
#undef YKLocalizedString
#endif
#define YKLocalizedString(__KEY__) [YKLocalized localize:__KEY__ tableName:nil value:nil] // LOCALIZE_KEY_IGNORE
#define YKLocalizedStringForLocale(__KEY__, __LOCALE__) [YKLocalized localize:__KEY__ tableName:nil locale:__LOCALE__]
#define YKLocalizedFormat(__KEY__, ...) [NSString stringWithFormat:[YKLocalized localize:__KEY__ tableName:nil value:nil], ##__VA_ARGS__] // LOCALIZE_KEY_IGNORE
#define YKLocalizedStringWithDefaultValue(__KEY__, __TABLE__, __VALUE__) [YKLocalized localize:__KEY__ tableName:__TABLE__ value:[YKLocalized localize:__VALUE__ tableName:__TABLE__ value:nil]]
#define YKLocalizedStringForTable(__TABLE__, __KEY__) [YKLocalized localize:__KEY__ tableName:__TABLE__ value:nil]

/*!
 Single/plural localized formats.
 
 For example:
 
       XMobilePhoto = "%d Photo";
       XMobilePhotos = "%d Photos";
       header = YKLocalizedCount(@"XMobilePhoto", @"XMobilePhotos", [item.bizLargePhotoURLs count]); // LOCALIZE_KEY_IGNORE

 or:

       MobilePhoto = "a photo"; // Does not include %d
       XMobilePhotos = "%d photos";
       header = YKLocalizedCount(@"MobilePhoto", @"XMobilePhotos", [item.bizLargePhotoURLs count]); // LOCALIZE_KEY_IGNORE

 */
#define YKLocalizedCount(__SINGULAR_KEY__, __PLURAL_KEY__, __COUNT__) (__COUNT__ == 1 ? \
  [NSString stringWithFormat:[YKLocalized localize:__SINGULAR_KEY__ tableName:nil value:nil], __COUNT__] : \
  [NSString stringWithFormat:[YKLocalized localize:__PLURAL_KEY__ tableName:nil value:nil], __COUNT__])

/*!
 Localized string from choice.
 YKLocalizedChoice(@"This", @"That", YES) => YKLocalizedString(@"This") // LOCALIZE_KEY_IGNORE
 YKLocalizedChoice(@"This", @"That", NO) => YKLocalizedString(@"That") // LOCALIZE_KEY_IGNORE
 */
#define YKLocalizedChoice(__KEY_TRUE__, __KEY_FALSE__, __BOOL__) (__BOOL__ ? \
  [YKLocalized localize:__KEY_TRUE__ tableName:nil value:nil] : \
  [YKLocalized localize:__KEY_FALSE__ tableName:nil value:nil])

/*!
 Localized language name (English, German, French, etc) from two-letter language code (en, de, fr, etc)
 */
#define YKLocalizedLanguageNameFromCode(languageCode) [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:languageCode]

/*!
 Patching localizedStringForKey method.
 There are issues with locales and localized resources not being picked up correctly.
 @see https://devforums.apple.com/thread/3210?tstart=0
 */
@interface NSBundle (YKLocalized)

/*!
 Localize string with key.
 
 Uses localized resource in order of: 
 - locale identifier (language_region): "en_CA"
 - language: "en"
 - no locale: nil
 
 If still not found will return the specified (default) value and finally will return the key as a last resort.
 
 @param key String to localize
 @param value Default localized string if key not found
 @param tableName Name of strings file, defaults to "Localizable"
*/
- (NSString *)yelp_localizedStringForKey:(NSString *)key value:(NSString *)value tableName:(NSString *)tableName;

/*!
 Localize string with key.
 
 Uses localized resource in order of: 
 - locale identifier (language_region): "en_CA"
 - language: "en"
 - no locale: nil
 
 If still not found will return the specified (default) value and finally will return the key as a last resort.
 
 @param key String to localize
 @param tableName Name of strings file, defaults to "Localizable"
 */
- (NSString *)yelp_localizedStringForKey:(NSString *)key tableName:(NSString *)tableName;

/*!
 Localize string to the given locale.
 
 Uses localized resource in order of:
 - locale parameter passed in (language_region): "en_CA"
 - language: "en"
 - device's current locale

 If still not found will return the key as a last resort.

 @param key String to localize
 @param tableName Name of strings file, defaults to "Localizable"
 @param locale The locale to localize to
 */
- (NSString *)yelp_localizedStringForKey:(NSString *)key tableName:(NSString *)tableName locale:(NSString *)locale;

/*!
 Get string for key based on localization.
 @param key String to localize
 @param tableName Name of strings file, defaults to "Localizable"
 @param localization Localization, e.g. "en_US" or "en"
 */
- (NSString *)yelp_stringForKey:(NSString *)key tableName:(NSString *)tableName localization:(NSString *)localization;

/*!
 Load resource bundle for table name and localization (cached).
 @param tableName Localizable
 @param localization Localization, e.g. "en_US" or "en"
 */
- (NSDictionary *)yelp_loadResourceForTableName:(NSString *)tableName localization:(NSString *)localization;

/*!
 Path for resource (cached).
 @param tableName Name of strings file, defaults to "Localizable"
 @param localization Localization, e.g. "en_US" or "en"
 */
- (NSString *)yelp_pathForResource:(NSString *)tableName localization:(NSString *)localization;

/*!
 Find useable language for table name.
 Falls back to @"en" if no language bundles found.
 @param tableName Name of strings file, defaults to "Localizable"
 */
- (NSString *)yelp_preferredLanguageForTableName:(NSString *)tableName;

/*!
 Clear any caching.
 */
+ (void)yelp_clearCache;

@end

/*!
 Wrapper for localization calls, that caches localized key/value pairs.
 */
@interface YKLocalized : NSObject { }

// Cache for localized strings
+ (NSMutableDictionary *)localizationCache;
// Clears the localization cache
+ (void)clearCache;

/*!
 Get localized string.
 
 @param key Key
 @param tableName The strings file to lookup. Defaults to Localizable (which uses Localizable.strings)
 @param value Default if key is not present
 */
+ (NSString *)localize:(NSString *)key tableName:(NSString *)tableName value:(NSString *)value;

/*!
 Get localized string for specified locale
 
@param key Key
@param locale The locale to localize to
*/
+ (NSString *)localize:(NSString *)key tableName:(NSString *)tableName locale:(NSString *)locale;

/*!
 Set default table name.
 @param defaultTableName Default table name. Defaults to "Localizable". Set to nil to reset to default.
 */
+ (void)setDefaultTableName:(NSString *)defaultTableName;

/*!
 Shortcut for determining if current locale is metric.
 */
+ (BOOL)isMetric;

/*!
 Shortcut for determining if current locale is metric.
 @param locale Locale
 */
+ (BOOL)isMetric:(id)locale;

/*!
 Shortcut for determining currency symbol.
 */
+ (NSString *)currencySymbol;

/*!
 Current locale identifier with correct language.
 Normally, [[NSLocale currentLocale] localeIdentifier] only returns the locale identifier
 relevant to the region format. That is, for language = Español and region format = US,
 [[NSLocale currentLocale] localeIdentifier] == @"en_US".
 @result Locale identifier string with correct language
 */
+ (NSString *)localeIdentifier;

/*!
 Get the country code (for locale region format). If supportedCountries is set, and the
 device's country code is not in supportedCountries, this will default to @"US".
 */
+ (NSString *)countryCode;

/*!
 Set the mock country code (for testing)
 */
+ (void)setMockCountryCode:(NSString *)countryCode;

/*!
 Disable the mock country code (for testing)
 */
+ (void)disableMockCountryCode;

/*!
 Current language code.
 @result Language code
 */
+ (NSString *)languageCode;

/*!
 Set supported languages.
 @param supportedLanguages List of supported languages
 */
+ (void)setSupportedLanguages:(NSSet *)supportedLanguages;

/*!
 Supported languages, or nil if not set.
 */
+ (NSSet *)supportedLanguages;

/*!
 Set supported countries.
 @param supportedCountries Set of supported countries
 */
+ (void)setSupportedCountries:(NSSet *)supportedCountries;

/*!
 Supported countries, or nil if not set.
 */
+ (NSSet *)supportedCountries;

// If country code (for phone locale region format)
+ (BOOL)isCountryCode:(NSString *)code;

/*!
 Get localized path.
 
 (1) Checks specific localized bundle directory (en_GB).
 (2) Otherwise, checks default localized  bundle directory (en).
 (3) Otherwise checks default bundle directory.
 
 @param name Name
 @param type Type
 @result Path to localized file
 */
+ (NSString *)localizedPath:(NSString *)name ofType:(NSString *)type;

/*!
 Localized list.
 
    [YKLocalized localizedListFromStrings:[NSArray arrayWithObjects:@"one", @"two", @"three", nil]]; => @"one, two and three"
 
 @param strings Strings
 */
+ (NSString *)localizedListFromStrings:(NSArray */*of NSString*/)strings;

/*!
 Correctly localized date formatter.
 [NSLocale currentLocale] seems to only use region format when figuring out the locale.
 (see discussion above [YKLocalized localeIdentifier]). This causes NSDateFormatter to
 localize based on the region format instead of the language. That means for phones in
 es_US, all the dates get localized as en_US. This method returns a date formatter that
 will correctly localize for the region
 @result Correctly localized NSDateFormatter
 */
+ (NSDateFormatter *)dateFormatter;

/*!
 Current locale with the correct language code.
 */
+ (NSLocale *)currentLocale;

@end

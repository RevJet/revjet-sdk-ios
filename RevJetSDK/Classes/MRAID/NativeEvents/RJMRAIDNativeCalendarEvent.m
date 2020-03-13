//
//  RJMRAIDNativeCalendarEvent.m
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import "RJMRAIDNativeCalendarEvent.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface RJMRAIDNativeCalendarEvent () <EKEventEditViewDelegate>

@property (nonatomic, strong) EKEventEditViewController *eventEditViewController;

- (EKEvent *)calendarEventFromParameters:(NSDictionary *)aParameters eventStore:(EKEventStore *)anEventStore;
- (NSDateFormatter *)dateFormatterForFormat:(NSString *)aFormat;

- (void)presentEditViewController;

@end

@implementation RJMRAIDNativeCalendarEvent

@synthesize eventEditViewController;

- (void)dealloc
{
	self.eventEditViewController.editViewDelegate = nil;
}

#pragma mark -

- (void)executeEventWithParameters:(NSDictionary *)aParameters
{
	[super executeEventWithParameters:aParameters];
	
	self.eventEditViewController.event = [self calendarEventFromParameters:aParameters
				eventStore:self.eventEditViewController.eventStore];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
	if ([self.eventEditViewController.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
	{
		[self.delegate nativeEventWillRequestAccess:self];
		[self.eventEditViewController.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:
		^(BOOL isGranted, NSError *anError)
		{
			[self.delegate nativeEventDidRequestAccess:self];
			if (isGranted)
			{
				dispatch_async(dispatch_get_main_queue(), ^
				{
					[self presentEditViewController];
				});
			}
			else
			{
				dispatch_async(dispatch_get_main_queue(), ^
				{
					[self reportErrorWithMessage:@"No access to the calendar"];
				});
			}
		}];
	}
	else
	{
		[self presentEditViewController];
	}
#else
	[self presentEditViewController];
#endif
}

#pragma mark - Private

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)aController
			didCompleteWithAction:(EKEventEditViewAction)anAction
{
	if (EKEventEditViewActionSaved == anAction)
	{
		BOOL isSaved = [aController.eventStore saveEvent:aController.event span:EKSpanThisEvent error:nil];
		if (!isSaved)
		{
			[self reportErrorWithMessage:@"Failed to store created event in the event store."];
		}
	}
	else if (EKEventEditViewActionCanceled == anAction)
	{
		[self reportErrorWithMessage:@"The saving action was canceled"];
	}

	[aController dismissViewControllerAnimated:YES completion:nil];
	[self.delegate nativeEventDidDismissModalView:self];
}

#pragma mark - Private

- (EKEventEditViewController *)eventEditViewController
{
	if (nil == eventEditViewController)
	{
		eventEditViewController = [[EKEventEditViewController alloc] init];
		eventEditViewController.editViewDelegate = self;
		eventEditViewController.eventStore = [[EKEventStore alloc] init];
	}
	
	return eventEditViewController;
}

#pragma mark -

- (EKEvent *)calendarEventFromParameters:(NSDictionary *)aParameters eventStore:(EKEventStore *)anEventStore
{
	EKEvent *theEvent = [EKEvent eventWithEventStore:anEventStore];
	theEvent.title = [aParameters objectForKey:@"description"];
	
	NSString *theStartDateString = [aParameters objectForKey:@"start"];
	if (nil != theStartDateString)
	{
		theEvent.startDate = [self dateFromString:theStartDateString];
	}
	
	NSString *theEndDateString = [aParameters objectForKey:@"end"];
	if (nil != theEndDateString)
	{
		theEvent.endDate = [self dateFromString:theEndDateString];
	}
	
	theEvent.location = [aParameters objectForKey:@"location"];
	theEvent.notes = [aParameters objectForKey:@"summary"];
	
	NSString *theAbsoluteReminderDateString = [aParameters objectForKey:@"absoluteReminder"];
	NSString *theRelativeReminderOffsetString = [aParameters objectForKey:@"relativeReminder"];
	if (nil != theAbsoluteReminderDateString)
	{
		NSDate *theAbsoluteReminderDate = [self dateFromString:theAbsoluteReminderDateString];
		if (nil != theAbsoluteReminderDate)
		{
			[theEvent addAlarm:[EKAlarm alarmWithAbsoluteDate:theAbsoluteReminderDate]];
		}
	}
	else if (nil != theRelativeReminderOffsetString)
	{
		[theEvent addAlarm:[EKAlarm alarmWithRelativeOffset:[theRelativeReminderOffsetString doubleValue]]];
	}
	
	NSString *theIntervalString = [aParameters objectForKey:@"interval"];
	if (nil != theIntervalString)
	{
		[theEvent addRecurrenceRule:[self recurrenceRuleWithParameters:aParameters
					interval:[theIntervalString integerValue]]];
	}
	
	theEvent.calendar = [anEventStore defaultCalendarForNewEvents];
	NSString *theTransparency = [aParameters objectForKey:@"transparency"];
	if ([theTransparency isEqualToString:@"transparent"])
	{
		theEvent.availability = EKEventAvailabilityFree;
	}
	else if ([theTransparency isEqualToString:@"opaque"])
	{
		theEvent.availability = EKEventAvailabilityBusy;
	}
	
	return theEvent;
}

- (NSDate *)dateFromString:(NSString *)aDateString
{
	NSRegularExpression *theRegEx = [NSRegularExpression regularExpressionWithPattern:@"[-+]\\d\\d:"
				options:NSRegularExpressionCaseInsensitive error:NULL];
	NSTextCheckingResult *theRegExResult = [theRegEx firstMatchInString:aDateString options:0
				range:NSMakeRange(0, [aDateString length])];
	NSString *theTimezone = [aDateString substringWithRange:[theRegExResult range]];
	theTimezone = [theTimezone stringByReplacingOccurrencesOfString:@":" withString:@""];
	NSString *theDateString = [theRegEx stringByReplacingMatchesInString:aDateString options:0
				range:NSMakeRange(0, [aDateString length]) withTemplate:theTimezone];
	
	NSArray *theDateFormatters = [NSArray arrayWithObjects:
				[self dateFormatterForFormat:@"yyyy-MM-dd'T'HH:mmZZZ"],
				[self dateFormatterForFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"], nil];
	NSDate *theResultDate = nil;
	for (NSDateFormatter *theFormatter in theDateFormatters)
	{
		theResultDate = [theFormatter dateFromString:theDateString];
		if (nil != theResultDate)
		{
			break;
		}
	}

	return theResultDate;
}

- (NSDateFormatter *)dateFormatterForFormat:(NSString *)aFormat
{
	NSDateFormatter *theFormatter = [[NSDateFormatter alloc] init];
	[theFormatter setDateFormat:aFormat];
	return theFormatter;
}

#pragma mark -

- (EKRecurrenceRule *)recurrenceRuleWithParameters:(NSDictionary *)aParameters interval:(NSInteger)anInterval
{
	EKRecurrenceFrequency theFrequency = [self getFrequencyWithParameters:aParameters];
	EKRecurrenceEnd *theRecurrenceEnd = [self getRecurrenceEndWithParameters:aParameters];
	NSArray *theDaysOfTheWeek = [self getDaysOfTheWeekFromParameters:aParameters];
	NSArray *theDaysInMonth = [self getDaysOfTheMonthFromParameters:aParameters];
	NSArray *theDaysInYear = [self getDaysOfTheYearFromParameters:aParameters];
	NSArray *theMonthsInYear = [self getMonthsOfTheYearFromParameters:aParameters];

	return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:theFrequency interval:anInterval
				daysOfTheWeek:theDaysOfTheWeek daysOfTheMonth:theDaysInMonth monthsOfTheYear:theMonthsInYear
				weeksOfTheYear:nil daysOfTheYear:theDaysInYear setPositions:nil end:theRecurrenceEnd];
}

- (EKRecurrenceFrequency)getFrequencyWithParameters:(NSDictionary *)aParameters
{
	NSString *theFrequency = [aParameters objectForKey:@"frequency"];
	if ([theFrequency isEqualToString:@"weekly"])
	{
		return EKRecurrenceFrequencyWeekly;
	}
	else if ([theFrequency isEqualToString:@"monthly"])
	{
		return EKRecurrenceFrequencyMonthly;
	}
	else if ([theFrequency isEqualToString:@"yearly"])
	{
		return EKRecurrenceFrequencyYearly;
	}
	return EKRecurrenceFrequencyDaily;
}

- (EKRecurrenceEnd *)getRecurrenceEndWithParameters:(NSDictionary *)aParameters
{
	EKRecurrenceEnd *theRecurrenceEnd = nil;
	NSString *theExpires = [aParameters objectForKey:@"expires"];
	if (nil != theExpires)
	{
		NSDate *theEndDate = [NSDate dateWithTimeIntervalSince1970:[theExpires doubleValue]];
		theRecurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:theEndDate];
	}
	return theRecurrenceEnd;
}

- (NSArray *)getDaysOfTheWeekFromParameters:(NSDictionary *)aParameters
{
	NSString *theDaysString = [aParameters objectForKey:@"daysInWeek"];
	NSArray *theDaysArray = [theDaysString componentsSeparatedByString:@","];
	NSMutableArray *theResultDays = [NSMutableArray array];
	for (NSString *dayValue in theDaysArray)
	{
		@try
		{
			EKRecurrenceDayOfWeek *theDay = [EKRecurrenceDayOfWeek dayOfWeek:[dayValue integerValue] + 1];
			[theResultDays addObject:theDay];
		}
		@catch (NSException *anException)
		{
			theResultDays = nil;
		}
	}
	
	return [NSArray arrayWithArray:theResultDays];
}

- (NSArray *)getTimeUnitsFromString:(NSString *)aString
{
	NSArray *theValuesArray = [aString componentsSeparatedByString:@","];
	NSMutableArray *theResultArray = [NSMutableArray array];
	for (NSString *theValue in theValuesArray)
	{
		NSInteger theValueInteger = [theValue integerValue] > 0 ? [theValue integerValue] : [theValue integerValue] - 1;
		[theResultArray addObject:[NSNumber numberWithInteger:theValueInteger]];
	}
	
	return [NSArray arrayWithArray:theResultArray];
}

- (NSArray *)getDaysOfTheMonthFromParameters:(NSDictionary *)aParameters
{
	return [self getTimeUnitsFromString:[aParameters objectForKey:@"daysInMonth"]];
}

- (NSArray *)getDaysOfTheYearFromParameters:(NSDictionary *)aParameters
{
	return [self getTimeUnitsFromString:[aParameters objectForKey:@"daysInYear"]];
}

- (NSArray *)getMonthsOfTheYearFromParameters:(NSDictionary *)parameters
{
	NSString *theMonthsString = [parameters objectForKey:@"monthsInYear"];
	NSArray *theMonthsArray = [theMonthsString componentsSeparatedByString:@","];
	NSMutableArray *theResultMonths = [NSMutableArray array];
	for (NSString *theMonthValue in theMonthsArray)
	{
		NSNumber *theMonthNumber = [NSNumber numberWithInteger:[theMonthValue integerValue]];
		[theResultMonths addObject:theMonthNumber];
	}
	
	return [NSArray arrayWithArray:theResultMonths];
}

#pragma mark -

- (void)presentEditViewController
{
	[self.delegate nativeEventWillPresentModalView:self];
	[[self.delegate viewControllerForPresentingModalView] presentViewController:self.eventEditViewController
				animated:YES completion:nil];
}

@end

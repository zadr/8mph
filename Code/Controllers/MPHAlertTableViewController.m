#import <MapKit/MapKit.h>

#import "MPHAlertTableViewController.h"

#import "MPHTableViewCell.h"

#import "MPHMessage.h"
#import "MPHStop.h"
#import "MPHNextBusStop.h"

#import "MPHAmalgamator.h"
#import "MPHAmalgamation.h"

#import "MPHAnnotation.h"
#import "MPHImageGenerator.h"

#import "NSStringAdditions.h"
#import "UIColorAdditions.h"

@interface MPHMapTableViewCell : UITableViewCell
@property (nonatomic, strong, readonly) MKMapView *mapView;
@end

@implementation MPHMapTableViewCell
- (instancetype) initWithStyle:(UITableViewCellStyle) style reuseIdentifier:(NSString *) reuseIdentifier {
	if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
		return nil;

	_mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
	_mapView.userInteractionEnabled = NO;
	_mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	_mapView.showsUserLocation = NO;
	_mapView.userTrackingMode = MKUserTrackingModeNone;

	[self.contentView addSubview:_mapView];

	return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];

	_mapView.frame = self.contentView.bounds;
}

- (void) prepareForReuse {
	[super prepareForReuse];

	[_mapView removeAnnotations:_mapView.annotations];
	[_mapView removeOverlays:_mapView.overlays];
}

@end

@interface MPHAlertTableViewController () <MKMapViewDelegate>
@end

@implementation MPHAlertTableViewController {
	MPHMessage *_message;
	MPHImageGenerator *_imageGenerator;
}

- (id) initWithMessage:(MPHMessage *) message {
	if (!(self = [super initWithStyle:UITableViewStyleGrouped]))
		return nil;

	_imageGenerator = [[MPHImageGenerator alloc] init];
	_message = message;

	if (_message.affectedLines.count == 1)
		self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ - Notices", @"%@ (line) - Notices"), [_message.affectedLines lastObject]];
	else self.title = NSLocalizedString(@"Notices", @"Notices view title");

	return self;
}

#pragma mark -

- (void) viewDidLoad {
	[super viewDidLoad];

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.contentInset = UIEdgeInsetsMake(12.0, 0.0, 0.0, 0.0);
}

#pragma mark -

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView {
	return 4;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
	if (section == 0)
		return _message.affectedLines.count;
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
	if (indexPath.section == 0) {
		MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if (!cell) {
			cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}

		NSString *routeTag = _message.affectedLines[indexPath.row];
		id <MPHRoute> route = [[MPHAmalgamator amalgamator] routeWithTag:routeTag onService:_message.service];

		NSRange dashRange = [route.name rangeOfString:@"-"];
		if ([route.name mph_hasCaseInsensitivePrefix:@"JBUS-"])
			cell.textLabel.text = @"Church Bus";
		else if ([route.name mph_hasCaseInsensitivePrefix:@"KTBU-"])
			cell.textLabel.text = @"Ingleside-Third Street Bus";
		else if ([route.name mph_hasCaseInsensitivePrefix:@"LBUS-"])
			cell.textLabel.text = @"Taraval Bus";
		else if ([route.name mph_hasCaseInsensitivePrefix:@"MBUS-"])
			cell.textLabel.text = @"Ocean View Bus";
		else if ([route.name mph_hasCaseInsensitivePrefix:@"NBUS-"])
			cell.textLabel.text = @"Judah Bus";
		else if (dashRange.location != NSNotFound)
			cell.textLabel.text = [route.name substringFromIndex:dashRange.location + dashRange.length];
		else cell.textLabel.text = route.name;

		NSString *text = dashRange.location != NSNotFound ? [route.name substringToIndex:dashRange.location] : route.tag;

		NSRange buRange = [text rangeOfString:@"BU"];
		text = buRange.location != NSNotFound ? [text substringToIndex:buRange.location] : text;

		UIImage *image = [_imageGenerator generateImageWithParameters:@{
			MPHImageFillColor: route.color,
			MPHImageStrokeColor: self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? route.color.mph_lightenedColor : route.color.mph_darkenedColor,
			MPHImageStrokeWidth: @(4 + self.view.window.screen.scale),
			MPHImageText: text,
			MPHImageFont: text.length <= 3 ? (text.length == 3 ? [UIFont systemFontOfSize:24] : [UIFont systemFontOfSize:28]) : [UIFont systemFontOfSize:22],
			MPHImageRadius: @(35)
		}];

		cell.imageView.contentMode = UIViewContentModeCenter;
		cell.imageView.image = image;
		cell.imageView.transform = CGAffineTransformMakeScale(.5, .5);

		return cell;
	} else if (indexPath.section == 1) {
		MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if (!cell) {
			cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}

		cell.textLabel.text = _message.text;
		cell.textLabel.numberOfLines = 0;
		cell.imageView.image = nil;

		return cell;
	} else if (indexPath.section == 2) {
		MPHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if (!cell) {
			cell = [[MPHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}

		id <MPHStop> stop = [[MPHAmalgamator amalgamator] stopsForMessage:_message onRouteTag:_message.affectedLines.firstObject].firstObject;
		cell.textLabel.text = stop.name;
		cell.imageView.image = nil;

		return cell;
	} else if (indexPath.section == 3) {
		MPHMapTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"map"];
		if (!cell) {
			cell = [[MPHMapTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"map"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}

		id <MPHStop> stop = [[MPHAmalgamator amalgamator] stopsForMessage:_message onRouteTag:_message.affectedLines.firstObject].firstObject;
		id<MPHRoute> route = [[MPHAmalgamator amalgamator] routeWithTag:_message.affectedLines.firstObject onService:stop.service];

		stop = [[MPHAmalgamator amalgamator] stopWithTag:@(stop.tag) onRoute:route onService:route.service inDirection:MPHDirectionNone];

		cell.mapView.centerCoordinate = stop.coordinate;
		cell.mapView.region =  MKCoordinateRegionMake(stop.coordinate, MKCoordinateSpanMake(MPHNearbyDefaultDistance, MPHNearbyDefaultDistance));

		MPHStopAnnotation *annotation = [MPHStopAnnotation annotationWithStop:stop route:route];
		[cell.mapView addAnnotation:annotation];

		return cell;
	}

	NSAssert(NO, @"oops");
	return nil;
}

#pragma mark -

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id <MKAnnotation>) annotation;
{
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
	if (!annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
		if ([annotation isKindOfClass:MPHStopAnnotation.class]) {
			MPHStopAnnotation *stopAnnotation = (MPHStopAnnotation *)annotation;
			annotationView.pinTintColor = stopAnnotation.route.color;
		}
		annotationView.animatesDrop = NO;
		annotationView.canShowCallout = YES;
	} else annotationView.annotation = annotation;

	return annotationView;
}

#pragma mark -

- (NSString *) _titleForHeaderInSection:(NSInteger) section {
	if (section == 0) {
		if (_message.affectedLines.count > 1)
			return @"Lines";
		return @"Line";
	}

	if (section == 1)
		return @"Message";

	if (section == 2)
		return @"Stop";

	return nil;
}

- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger) section {
	if (section == 3)
		return nil;

	UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
		headerView.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
		headerView.textLabel.numberOfLines = 0;
	}

	headerView.textLabel.text = [self _titleForHeaderInSection:section];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 50;
	}

	if (indexPath.section == 3) {
		return tableView.frame.size.width;
	}

	return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section {
	return 30.;
}

@end

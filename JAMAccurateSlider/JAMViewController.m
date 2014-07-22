
#import "JAMViewController.h"
#import "JAMAccurateSlider.h"

@interface JAMViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet JAMAccurateSlider *slider;

@end

@implementation JAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sliderDidChange:nil];
}

- (IBAction)sliderDidChange:(id)sender
{
    self.label.text = [NSString stringWithFormat:@"slider value: %0.3f", self.slider.value];
}

@end

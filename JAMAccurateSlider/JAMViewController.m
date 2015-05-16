
#import "JAMViewController.h"
#import "JAMAccurateSlider.h"
#import "JAMAccurateSlider-Swift.h"

@interface JAMViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet JAMAccurateSlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet AccurateSlider *slider2;

@end

@implementation JAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sliderDidChange:nil];
    [self slider2Changed:nil];
}

- (IBAction)sliderDidChange:(id)sender
{
    self.label.text = [NSString stringWithFormat:@"slider value: %0.3f", self.slider.value];
}

- (IBAction)slider2Changed:(UISlider *)sender;
{
    self.label2.text = [NSString stringWithFormat:@"swift slider value: %0.3f", self.slider2.value];
}

@end

package junitRunner;

import cucumber.api.CucumberOptions;
import cucumber.api.junit.Cucumber;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@CucumberOptions(plugin = {"pretty", "html:target/cucumber"}, 
dryRun=true, monochrome=true, 
features= {"classpath:feature/us14.feature"}, 
glue= {""})
public class RunCucumberTest {
}
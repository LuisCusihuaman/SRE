# 0) Install the eb cli
```
pip install awsebcli --user
```

# 1) Create a project
```
mkdir HelloWorld
cd HelloWorld
eb init --profile aws-devops
echo "Hello World" > index.html
eb create dev-env
```

# 2) configurations

```
# this backs up the current dev environment configuration
eb config save dev-env --cfg initial-configuration

# this sets an environment variable on the environment
eb setenv ENABLE_COOL_NEW_FEATURE=true

# save our config from the current state of our environment
eb config save dev-env --cfg prod
```

make changes to `.elasticbeanstalk/saved_configs/prod.cfg.yml`
- add an environment variable
- add auto scaling rules
```
  AWSEBAutoScalingScaleUpPolicy.aws:autoscaling:trigger:
    UpperBreachScaleIncrement: '2'
  AWSEBCloudwatchAlarmLow.aws:autoscaling:trigger:
    LowerThreshold: '20'
    MeasureName: CPUUtilization
    Unit: Percent
  AWSEBCloudwatchAlarmHigh.aws:autoscaling:trigger:
    UpperThreshold: '50'
```

then update the saved prod configuration
```
eb config put prod
```

Update current environments from saved configurations
```
eb config dev-env --cfg prod
```


# 3) Environment swap

Create new environments from saved configurations
```
# you can create environments from configurations
eb create prod-env --cfg prod
```
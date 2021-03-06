# Alerting and Recording Rules

### Step 1 - Setup env

```bash
vagrant global-status
vagrant up
vagrant status
```

Te new instance will be available for inspection and the Prometheus web interface will be accessible
at http://192.168.42.10:9090.

```bash
vagrant ssh prometheus
```

### Cleanup

```bash
vagrant destroy -f
```

# How rule evaluation works

Prometheus allow the periodic evaluation of PromQL expressions and the storage of the time series generated by them,
they are called **rules**, separated in _recording_ and _alerting rules_.

The recording rules' evaluation results are saved into the Prometheus database as samples for the time series specified
in the configuration.

Alerting rules trigger when an evaluated PromQL expression in a rule produces a non-empty result.

# What is an alerting rule?

An alerting rule is much like a recording rule with some additional definitions; they can even share the same rule group
withoud any issues. We are talking about when the current state differs from desired state, which boils down (reduce) to
when the expressions returns one or more samples.

1. What are the primary uses for recording rules?

This type of rules can help take the load off heavy dashboards by pre-computing expensive queries, aggregate raw data
into time series that can then be exported to external systems, and assist the creation of compound range vector
queries.

2. Why should you avoid setting different evaluation intervals in rule groups?

For the same reasons as in scrape jobs, queries might produce erroneous results when using series with different
sampling rates, and having to keep track of what series have what periodicity becomes unmanageable.

3. If you were presented with the instance_job:latency_seconds_bucket:rate30s metric, what labels would you expect to
   find and what would be the expression used to record it?

instance_job:latency_seconds_bucket:rate30s needs to have at least the instance and job labels. It was calculated by
applying the rate to the latency_seconds_bucket_total metric, using a 30-second range vector.

4. Why is using the sample value of an alert in the alert labels a bad idea?

As that label changes its value, so will the identity of the alert.

5. What is the pending state of an alert?

An alert enters the pending state when it starts triggering (its expression starts returning results), but the for
interval hasn't elapsed yet to be considered firing.

6. How long would an alert wait between being triggered and transitioning to the firing state when the for clause is not
   specified?

It would be immediate. When the for clause isn't specified, the alert will be considered firing as soon as its
expression produces results.

7. How can you test your rules without using Prometheus?

The promtool utility has a test sub-command that can run unit tests for recording and alerting rules.

The tests of the IDL bindings use [mgunit] for the unit testing framework, which
is not provided. Obtain it from GitHub to be able to run the unit tests with:

``` IDL
IDL> mgunit, 'mlsoapiclient_uts'
```

To test using a local server, use the `LOCAL` property to the test cases:

``` IDL
IDL> mgunit, 'mlsoapiclient_uts', /local
```


[mgunit]: https://github.com/mgalloy/mgunit/tree/master

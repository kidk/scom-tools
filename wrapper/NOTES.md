# Running
`cscript /nologo ./example.vbs`

# How it works

1) We include NewRelic.class.vbs into the existing script. Add it to the end of the file.
2) Replace `Set oAPI = CreateObject("Mom.ScriptAPI")` with `Set oAPI = new NewRelic`
3) Done

# It might be a dumbass

All VBS scripts return xml

```
<DataItem type="System.PropertyBagData" time="2021-01-11T14:52:48.6877144+00:00" sourceHealthServiceId="C9009D1C-DFE8-2BE3-986C-80DC47CD6CA2">
    <Property Name="State" VariantType="8">BAD</Property>
    <Property Name="ErrorString" VariantType="8">The number of command line arguments is incorrect: Expected: 3 Actual: 0</Property>
</DataItem>
```

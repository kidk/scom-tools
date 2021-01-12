Class NewRelicResultBag

  Public metricTypes(255)
  Public metricValues(255)
  Public counter

  Sub AddValue(metricType, metricValue)
    metricTypes(counter) = metricType
    metricValues(counter) = metricValue
    counter = counter + 1
  End Sub

  Sub PrintJson()
    Wscript.Echo "{"
    For counter = 0 To counter - 1
      Wscript.Echo "    """ & metricTypes(counter) & """: """ & metricValues(counter) & ""","
    Next
    Wscript.Echo "    ""EventType"": ""SCOM"""
    Wscript.Echo "}"
  End Sub

End Class

Class NewRelic

  Public metricBags(255)
  Public counter

  Function CreateTypedPropertyBag(propertyType)
    Set CreateTypedPropertyBag = new NewRelicResultBag
  End Function

  Sub AddItem(metricBag)
    Set metricBags(counter) = metricBag
    counter = counter + 1
  End Sub

  Sub ReturnItems()
    Dim metricBag
    For Each metricBag in metricBags
      If Not isEmpty(metricBag) Then
        metricBag.PrintJson
      End If
    Next
  End Sub

End Class

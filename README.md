# Evebury.Gs1.Message
[![License](https://img.shields.io/github/license/Evebury/Evebury.Gs1.Message)](LICENSE.txt)
[![NuGet](https://img.shields.io/nuget/v/Evebury.Gs1.Message)](https://www.nuget.org/packages/Evebury.Gs1.Message/)
[![Nuget](https://img.shields.io/nuget/dt/Evebury.Gs1.Message)](https://www.nuget.org/packages/Evebury.Gs1.Message)

A comprehensive .NET library for validating GDSN GS1 messages. This engine acts as a pre-validation layer, ensuring data quality and compliance before messages are delivered to the GS1 Network.

## 🚀 Features
- **Reduce API Costs**: Prevent unnecessary calls and potential "rate limit" issues by catching errors early and locally.
- **UI**: Display custom friendly localized messages. 
- **Smart delta updates**: Compare the message with a last successful update. Prevent forwarding to the GS1 Network if unaltered.
- **Data Integrity**: Ensure 100% compliance with GS1 XML schemas and complex business rules. If the message does not comply do not forward to the GS1 Network.
- **Operational Efficiency**: Use advanced responses with XPaths to pinpoint data errors instantly, reducing manual troubleshooting time.

## 📊 Supported GDSN GS1 Messages

| Message                                      | Version  | Schema | Equality | Rules* |
|----------------------------------------------|----------|--------|----------|-------|
| `catalogueItemNotificationMessage`           | 3.1      | ✅     | ✅      | ✅    |
| `gS1ResponseMessage`                         | 3.1      | ✅     | ✅      |       |
| `catalogueItemHierarchicalWithdrawalMessage` | 3.1      | ✅     | ✅      | ✅    |
| `catalogueItemPublicationMessage`            | 3.1      | ✅     | ✅      | ✅    |
| `catalogueItemConfirmationMessage`           | 3.1      | ✅     | ✅      |       |
| `catalogueItemRegistrationResponseMessage`   | 3.1      | ✅     | ✅      |       |
| `catalogueItemSubscriptionMessage`           | 3.1      | ✅     | ✅      |       |

*\* if not indicated rules do not apply for this message type*

## 📊 Localized Validation Messages
|Language | Support|
|---------|--------|
| `en`, `nl`, `fr`, `de` | ✅ |

*\*schema and network messages if applicable default to English*

## 🔧 GDSN version
- **Current v3.1.33 (November 2025)**

## 🔧 Current rule status
- **Rules to be moved to schema**:  541, 542, 1061, 1407, 1380
- **Rules specified invalid**: 550, 633, 1013, 1408, 1670, 1672, 1674, 1676, 1678
- **Rules that can not be implemented**: 1316: checks if GTIN exists in the GS1 datapool.

## 🎯 Quick Start

```csharp
using Evebury.Gs1.Message;
using System.Globalization;
using System.Xml;

// Load the message
XmlDocument message = new();
message.Load("catalogueItemNotificationMessage.xml");

// Load optional previously sucessfuly published message
XmlDocument previous = new();
previous.Load("catalogueItemNotificationMessageLastSucceeded.xml");

// Create the validator
Validator validator = new();

//this call will apply schema, compare and apply business rules
Response response = validator.Validate(message, previous);

// set the cultureinfo to localize the reponse
CultureInfo cultureInfo = new("nl");
response.Localize(cultureInfo);

// Check if OK or ERROR
Console.WriteLine(response.Status == StatusType.OK);

```

```xml
<?xml version="1.0" encoding="utf-8"?>
<Response Id="validation_response" TimeStamp="2026-02-25T11:39:48.1277672Z" Status="ERROR" xmlns="urn:evebury:gdsn:gs1:response:1">
	<Transactions>
		<Transaction Id="[id]" Status="REJECTED">
			<Events>
				<Event Level="ERROR" Id="1289" Message="Als 'targetMarketCountryCode' niet gelijk is aan (036 (Australië), 554 (Nieuw-Zeeland)) en als 'firstShipDateTime' kleiner dan of gelijk is aan de huidige datum, dan mag 'preliminaryItemStatusCode' niet gelijk zijn aan 'PRELIMINARY'.">
					<Data Key="information_provider" Value="[information provider] ([gln])" Label="Informatieprovider" />
					<Data Key="market" Value="Duitsland (276)" Label="Markt" />
					<Data Key="trade_partner" Value="[tradepartner] ([gln])" Label="Klant" />
					<Data Key="catalogue_item" Value="BASE_UNIT_OR_EACH ([gtin])" Label="Catalogusitem" />
					<Data Key="xpath" Value="/catalogue_item_notification:catalogueItemNotificationMessage/transaction[transactionIdentification/entityIdentification ='[id]']/documentCommand/catalogue_item_notification:catalogueItemNotification/catalogueItem[tradeItem/gtin = '[pallet gtin]']/catalogueItemChildItemLink/catalogueItem[tradeItem/gtin = '[case gtin]']/catalogueItemChildItemLink/catalogueItem[tradeItem/gtin = '[base unit gtin]']/tradeItem/tradeItemInformation/extension/delivery_purchasing_information:deliveryPurchasingInformationModule/deliveryPurchasingInformation" />
				</Event>
			</Events>
		</Transaction>
	</Transactions>
</Response>
```


## 🏗️ Architecture

### Core Components

- **`Validator`** - Validator for all message validations
- **`Response`** - The response to all message operations


### Response

```csharp
//You can use this Reponse in the actual delivery allowing to work with one response object.

// Create the validator
Validator validator = new();

//see quick start and validate the message first then after actual delivery parse the received GS1 Response message:
Response response = await validator.ConvertGs1Response([gS1ResponseMessage.xml], true);

//if true response was rendered before actual delivery to the GS1 Network. = False
bool isValidationResponse = response.IsValidationResponse;

//use ToJson(), ToXmlDocument() or ToXhtml(CultureInfo cultureInfo = null, string iFormat = null) to process the response in your application

```


## 📋 Requirements & Enterprise support

- **.NET 10.0** or later
- **Memory**: Varies on the message size. Schema, Extension and Rules will be cached but can be reset by clearing the buffer.
- **Dependencies**: None (pure .NET implementation)
> ### 💡 Need a different version?
> While we target .NET 10 for maximum performance, we provide **custom builds and integration support** for organizations running on **any other Framework**.
> [Contact evebury for custom builds or professional services](https://www.evebury.com)

## 🐛 Error Handling

The library provides specific exceptions for common scenarios:

- `MessageException`: The message is not valid for current operation.
- `ArgumentNullException`: Message can not be null

## ℹ️ Help
> Want to learn more about **GDSN GS1 MESSAGES** or syndicating your data to **GS1**? Or anything else? We would love to hear from you! Reach out to us at: [Evebury](https://www.evebury.com).

*This library implements the GDSN GS1 specification with focus on practical syndication applications.*

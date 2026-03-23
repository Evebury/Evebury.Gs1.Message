<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl gs1"
    xmlns:gs1="urn:xsl:extension:gdsn:gs1:response"
	>
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="*" mode="measurementUnit">
		<!-- gets the normalized value for calculation purposes -->
		<xsl:variable name="value" select="."/>
		<xsl:variable name="unit" select="@measurementUnitCode"/>
		<xsl:choose>
			<xsl:when test="$unit = 'KGM'">
				<xsl:value-of select="$value * 1000"/>
			</xsl:when>
			<xsl:when test="$unit = 'GRM'">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:when test="$unit = 'MGM'">
				<xsl:value-of select="$value * 0.001"/>
			</xsl:when>
			<xsl:when test="$unit = 'MCG'">
				<xsl:value-of select="$value * 0.000001"/>
			</xsl:when>
			<xsl:when test="$unit = 'H87'">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:when test="$unit = 'EA'">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:when test="$unit = 'MTR'">
				<xsl:value-of select="$value * 1000"/>
			</xsl:when>
			<xsl:when test="$unit = 'CMT'">
				<xsl:value-of select="$value * 10"/>
			</xsl:when>
			<xsl:when test="$unit = 'MMT'">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:when test="$unit = 'CLT'">
				<xsl:value-of select="$value * 0.01"/>
			</xsl:when>
			<xsl:when test="$unit = 'LTR'">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="gs1:AddExceptionEvent('measurementUnitCode', concat('Provided unit is not implemented ', local-name(), ' ', $unit))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="measurementUnitType">
		<xsl:variable name="unit" select="@measurementUnitCode"/>
		<xsl:choose>
			<xsl:when test="$unit = 'KGM'">
				<xsl:value-of select="'Weight'"/>
			</xsl:when>
			<xsl:when test="$unit = 'GRM'">
				<xsl:value-of select="'Weight'"/>
			</xsl:when>
			<xsl:when test="$unit = 'MGM'">
				<xsl:value-of select="'Weight'"/>
			</xsl:when>
			<xsl:when test="$unit = 'MCG'">
				<xsl:value-of select="'Weight'"/>
			</xsl:when>
			<xsl:when test="$unit = 'H87'">
				<xsl:value-of select="'Piece'"/>
			</xsl:when>
			<xsl:when test="$unit = 'EA'">
				<xsl:value-of select="'Piece'"/>
			</xsl:when>
			<xsl:when test="$unit = 'CMT'">
				<xsl:value-of select="'Length'"/>
			</xsl:when>
			<xsl:when test="$unit = 'MTR'">
				<xsl:value-of select="'Length'"/>
			</xsl:when>
			<xsl:when test="$unit = 'MMT'">
				<xsl:value-of select="'Length'"/>
			</xsl:when>
			<xsl:when test="$unit = 'CLT'">
				<xsl:value-of select="'Volume'"/>
			</xsl:when>
			<xsl:when test="$unit = 'LTR'">
				<xsl:value-of select="'Volume'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="gs1:AddExceptionEvent('measurementUnitCode', concat('Provided unit is not implemented ', local-name(), ' ', $unit))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--

<Units>
  <Unit Name="Grams Per Cubic Centimetre" Code="23" Definition="Grams Per Cubic Centimetre: Grams Per Cubic Centimetre" />
  <Unit Name="Microlitre" Code="4G" Definition="Microlitre: A microlitre is one millionth of a litre" />
  <Unit Name="Micrometre" Code="4H" Definition="Micrometre: A micrometre is one millionth of a metre, also termed Micron." />
  <Unit Name="Net kilogram" Code="58" Definition="Net kilogram: A unit of mass defining the total number of kilograms after deductions." />
  <Unit Name="Part per million" Code="59" Definition="Part per million: A unit of proportion equal to 10-6 (ppm)." />
  <Unit Name="Batch" Code="5B" Definition="Batch: A unit of count defining the number of batches (batch: quantity of material produced in one operation or number of animals or persons coming at once)." />
  <Unit Name="Year" Code="ANN" Definition="Year: Unit of time equal to 365,25 days." />
  <Unit Name="Troy Ounce or Apothecary Ounce" Code="APZ" Definition="Troy ounce or apothecary ounce: The troy ounce is a unit of imperial measure. In the present day it is most commonly used to gauge the weight and therefore the price of precious metals.  One troy ounce equals 480 grains or 31.1035 grams." />
  <Unit Name="Assortment" Code="AS" Definition="Assortment: A unit of count defining the number of assortments (assortment: set of items grouped in a mixed collection)." />
  <Unit Name="Base box" Code="BB" Definition="Base box: A unit of area of 112 sheets of tin mil products (tin plate, tin free steel or black plate) 14 by 20 inches, or 31,360 square inches." />
  <Unit Name="Board Foot" Code="BFT" Definition="Board Foot: A specialized unit of measure for the volume of rough lumber (before drying and planing with no adjustments) or planed/surfaced lumber. It is the volume of a one-foot length of a board one foot wide and one inch thick. Some countries utilize the synonym super foot or superficial foot." />
  <Unit Name="Barrel US" Code="BLL" Definition="Barrel US: There are varying standards for barrel for some specific commodities, including 31 gal for beer, 40 gal for whiskey or kerosene, and 42 gal for petroleum. The general standard for liquids is 31.5 gal or half a hogshead; the general standard for dry contents is 7,056 Cubic Inches." />
  <Unit Name="Hundred board Foot" Code="BP" Definition="Hundred board foot: A unit of volume equal to one hundred board foot." />
  <Unit Name="British Thermal Unit" Code="BTU" Definition="British thermal unit: The British thermal unit (BTU or Btu) is a traditional unit of energy. It is approximately the amount of energy needed to heat one pound of water one degree Fahrenheit. One Btu is equal to about 1.06 kilojoules. It is used in the power, steam generation, heating and air conditioning industries." />
  <Unit Name="Bushel (US)" Code="BUA" Definition="Bushel (US): A bushel is an imperial and U.S. customary unit of dry volume, equivalent in each of these systems to 4 pecks or 8 gallons. It is used for volumes of dry commodities (not liquids), most often in agriculture" />
  <Unit Name="Bushel (UK)" Code="BUI" Definition="Bushel (UK): A bushel is an imperial and U.S. customary unit of dry volume, equivalent in each of these systems to 4 pecks or 8 gallons. It is used for volumes of dry commodities (not liquids), most often in agriculture" />
  <Unit Name="Millimole" Code="C18" Definition="Millimole: a millimole is one thousandth of a mole." />
  <Unit Name="Millisecond" Code="C26" Definition="Millisecond: A millisecond (from milli- and second; abbreviation: ms) is a thousandth (1/1000) of a second." />
  <Unit Name="Centigram " Code="CGM" Definition="Centigram: A centigram is one hundredth (1/100) of a gram" />
  <Unit Name="Centilitre" Code="CLT" Definition="Centilitre: A centilitre is one hundredth (1/100) of a litre" />
  <Unit Name="Square Centimetre " Code="CMK" Definition="Square centimetre: A square centimetre is an area of a square whose sides are exactly 1 centimetre in length." />
  <Unit Name="Cubic Centimetre " Code="CMQ" Definition="Cubic centimetre: A cubic centimetre is the volume of a cube of side length one centimetre (0.01 m) equal to a millilitre." />
  <Unit Name="Centimetre" Code="CMT" Definition="Centimetre: A centimetre is  equal to one hundredth of a metre." />
  <Unit Name="Hundred pound (cwt) / hundred weight (US)" Code="CWA" Definition="Hundred pound (cwt) / hundred weight (US): A unit of weight in the U.S. Customary System equal to 100 pounds (45.36 kilograms); also called cental." />
  <Unit Name="Hundred weight (UK)" Code="CWI" Definition="Hundred weight (UK):  A unit of weight in the British Imperial System equal to 112 pounds (50.80 kilograms); also called quintal." />
  <Unit Name="Terajoule " Code="D30" Definition="Terajoule: A terajoule is 10¹² joules" />
  <Unit Name="Terawatt Hour" Code="D32" Definition="Terawatt hour: A terawatt hour is 109 * kilowat hour or 3.6 petajoules." />
  <Unit Name="Calorie - International Table (IT)" Code="D70" Definition="This code is being DEPRECATED. Use code E14 Kilocalorie to express food calories. Calorie - International Table (IT): A calorie is 1/100 of the amount of energy required to warm one gram of air-free water from 0 °C to 100 °C at standard atmospheric pressure; this is about 4.190 J.  Its use is archaic, having been replaced by the SI unit of energy, the joule. However, in many countries it remains in common use as a unit of food energy. In the context of nutrition, and especially food labeling, the calorie is approximately equal to 4.1868 joules (J), and energy values are normally quoted in kilojoules (kJ) and kilocalories (kcal)." />
  <Unit Name="Days " Code="DAY" Definition="Days: A day is one three hundreds and sixty fifth (1/365) of a year" />
  <Unit Name="Decigram" Code="DG" Definition="Decigram: A decigram is one tenth (1/10) of a gram." />
  <Unit Name="Decilitre" Code="DLT" Definition="Decilitre: A decilitre is one tenth (1/10) of a litre." />
  <Unit Name="Square decimetre" Code="DMK" Definition="Square decimetre: A square deciimetre is an area of a square whose sides are exactly 1 deciimetre in length." />
  <Unit Name="Cubic decimetre" Code="DMQ" Definition="Cubic decimetre: A cubic decimetre is the volume of a cube of side length one decimetre (0.1 m)" />
  <Unit Name="Decimetre " Code="DMT" Definition="Decimetre: A decimetre is  equal to one tenth of a metre." />
  <Unit Name="Dram (US)" Code="DRA" Definition="Dram (US): The dram (archaic spelling drachm) was historically both a coin and a weight. Currently it is both a small mass in the Apothecaries' system of weights and a small unit of volume. This unit is called more correctly fluid dram or in contraction also fluidram. The term also refers to the fluid dram, a measure of capacity equal 1⁄8 of a fluid ounce, which means it is exactly equal to 3.696 691 195 312 5 mL in the United States." />
  <Unit Name="Dram (UK)" Code="DRI" Definition="Dram (UK): The dram (archaic spelling drachm) was historically both a coin and a weight. Currently it is both a small mass in the Apothecaries' system of weights and a small unit of volume. This unit is called more correctly fluid dram or in contraction also fluidram. The fluid dram is defined as 1⁄8 of a fluid ounce, which means it is exactly equal to 3.551 632 812 500 0 mL in the Commonwealth and Ireland. In England dram came to mean a small draught of cordial or alcohol; hence the term dram-house for the taverns where one could purchase a dram." />
  <Unit Name="Dozen " Code="DZN" Definition="Dozen: A unit of count defining the number of units in multiples of 12." />
  <Unit Name="Kilocalorie (international table)" Code="E14" Definition="Kilocalorie (international table): A unit of energy equal to 1000 calories." />
  <Unit Name="Dose" Code="E27" Definition="Dose: A unit of count defining the number of doses (dose: a definite quantity of a medicine or drug)." />
  <Unit Name="Gross kilogram " Code="E4" Definition="Gross kilogram: A unit of mass defining the total number of kilograms before deductions." />
  <Unit Name="Use" Code="E55" Definition="Use: A unit of count defining the number of times an object is used." />
  <Unit Name="Each" Code="EA" Definition="Each: A unit of count defining the number of items regarded as separate units." />
  <Unit Name="Micromole" Code="FH" Definition="Micromole: One millionth (10 -6 ) of a mole." />
  <Unit Name="Foot" Code="FOT" Definition="Foot: The international foot is defined to be equal to 0.3048 meters. " />
  <Unit Name="Square Foot " Code="FTK" Definition="Square foot: A square foot is an area of a square whose sides are exactly 1 foot in length." />
  <Unit Name="Cubic Foot" Code="FTQ" Definition="Cubic foot: A cubic foot is the volume of a cube of side length one foot (0.3048 m) ." />
  <Unit Name="Peck " Code="G23" Definition="Peck: A peck is an imperial and U.S. customary unit of dry volume, equivalent in each of these systems to 2 gallons, 8 dry quarts, or 16 dry pints." />
  <Unit Name="Tablespoon" Code="G24" Definition="Tablespoon: Tablespoon. 1/2 fluid ounces, 3 teaspoons, 15 millilitres" />
  <Unit Name="Teaspoon" Code="G25" Definition="Teaspoon: Teaspoon. 1/6 fluid ounces or  5 millilitres" />
  <Unit Name="Gallon (UK)" Code="GLI" Definition="Gallon (UK): The imperial (UK) gallon was legally defined as 4.54609 litres." />
  <Unit Name="Gallon (US)" Code="GLL" Definition="Gallon (US): The U.S. liquid gallon is legally defined as 231 cubic inches, and is equal to exactly 3.785411784 litres or about 0.133680555 cubic feet." />
  <Unit Name="Gram Per Square Metre " Code="GM" Definition="&quot;Gram per square metre: In the metric system, the density of all types of paper, paperboard, and fabric, is expressed in terms of grams per square meter (g/m²).  This quantity is commonly called grammage both in English and French (ISO 536), though many English-speaking countries still refer to the &quot;weight&quot;. The term density here is used somewhat incorrectly, as density is mass by volume. More precisely, it is a measure of the area density, areal density, or surface density.&quot;" />
  <Unit Name="Gram: " Code="GRM" Definition="Gram: A gram is defined as one one-thousandth of the kilogram (1×10-3 kg)." />
  <Unit Name="Grain" Code="GRN" Definition="Grain: A grain or troy grain is precisely 64.79891 milligrams. Exactly 7,000 grains per avoirdupois pound." />
  <Unit Name="Gross" Code="GRO" Definition="Gross: A unit of count defining the number of units in multiples of 144 (12 x 12)." />
  <Unit Name="Gigawatt Hour" Code="GWH" Definition="Gigawatt hour: A gigaawatt hour is 109 kilowat hour or 3.6 terajoules." />
  <Unit Name="Piece" Code="H87" Definition="Piece: A unit of count defining the number of pieces (piece: a single item, article or exemplar)." />
  <Unit Name="Hundred Count" Code="HC" Definition="Hundred count: A unit of count defining the number of units counted in multiples of 100." />
  <Unit Name="Half Dozen " Code="HD" Definition="Half dozen: A unit of count defining the number of units in multiplt of six (6)." />
  <Unit Name="Hectogram" Code="HGM" Definition="Hectogram: A hectogram is one hundred (100) grams" />
  <Unit Name="Hectolitre" Code="HLT" Definition="Hectolitre: A hectolitre is one hundred (100) litres." />
  <Unit Name="Hour" Code="HUR" Definition="Hour: An hour is a unit of measurement of time of the duration of 60 minutes, or 3600 seconds. It is 1/24 of a median Earth day." />
  <Unit Name="Inches" Code="INH" Definition="Inches: An international inch is defined to be equal to 25.4 millimeters." />
  <Unit Name="Square Inch" Code="INK" Definition="Square inch: A square inch is an area of a square whose sides are exactly 1 inch in length." />
  <Unit Name="Cubic Inch " Code="INQ" Definition="Cubic inch: A cubic inch is the volume of a cube of side length one inch (0.254 m)." />
  <Unit Name="Joule" Code="JOU" Definition="Joule: A joule is the energy exerted by a force of one newton acting to move an object through a distance of one metre." />
  <Unit Name="Kilolitre" Code="K6" Definition="Kilolitre: A kilolitre is one thousand (1000) litres." />
  <Unit Name="Kilogram" Code="KGM" Definition="Kilogram: A unit of mass equal to one thousand grams." />
  <Unit Name="Kilojoule" Code="KJO" Definition="Kilojoule: A kilojoule is 1000 joules" />
  <Unit Name="Kilometre" Code="KMT" Definition="Kilometre: A kilometre is one thousand (1000) metres" />
  <Unit Name="Kit" Code="KT" Definition="Kit: A unit of count defining the number of kits (kit: tub, barrel or pail)." />
  <Unit Name="Kilowatt Hour" Code="KWH" Definition="Kilowatt hour: A kilowatt hour is a unit of energy equal to 3.6 megajoules. It is also a common commercial unit of electric energy representing the amount of energy delivered at a rate of 1,000 watts over a period of one hour." />
  <Unit Name="Kilowatt" Code="KWT" Definition="Kilowatt: A kilowatt is one thousand (1000) watts" />
  <Unit Name="Pound" Code="LBR" Definition="Pound: The international avoirdupois pound of exactly 0.45359237 kilogram." />
  <Unit Name="Linear Foot" Code="LF" Definition="Linear foot: A unit of count defining the number of feet (12-inch) in length of a uniform width object." />
  <Unit Name="Link" Code="LK" Definition="Link: A unit of distance equal to 0.01 chain." />
  <Unit Name="Linear Metre" Code="LM" Definition="Linear metre: A unit of count defining the number of metres in length of a uniform width object." />
  <Unit Name="Layer " Code="LR" Definition="Layer: A unit of count defining the number of layers." />
  <Unit Name="Ton (UK) or long ton (US)" Code="LTN" Definition="Ton (UK) or long ton (US): Ton (UK) = 1016 Kg or 2240 Lb." />
  <Unit Name="Litre " Code="LTR" Definition="Litre: A litre is defined as a special name for a cubic decimetre (1 L = 1 dm3 = 1000 cm3)." />
  <Unit Name="Megawatt" Code="MAW" Definition="Megawatt: A unit of power defining the rate of energy transferred or consumed when a current of 1000 amperes flows due to a potential of 1000 volts at unity power factor." />
  <Unit Name="Microgram " Code="MC" Definition="Microgram: A microgram is one millionth of a gram (0.000001)" />
  <Unit Name="Milligram" Code="MGM" Definition="Milligram: A milligram is one thousandth of a gram (0.001)" />
  <Unit Name="Square mile" Code="MIK" Definition="Square mile: A square mile is an area of a square whose sides are exactly 1 mile in length." />
  <Unit Name="Minute (unit of time)" Code="MIN" Definition="Minute (unit of time): A minute is a unit of time equal to 1/60th of an hour or 60 seconds" />
  <Unit Name="Millilitre" Code="MLT" Definition="Millilitre: A millilitre is one thousandth of a litre (0.001)" />
  <Unit Name="Square millimetre" Code="MMK" Definition="Square millimetre: A square millimetre is an area of a square whose sides are exactly 1 millimetre in length." />
  <Unit Name="Cubic millimetre" Code="MMQ" Definition="Cubic millimetre: A cubic millimetre is the volume of a cube of side length one milliimetre (0.001 m)" />
  <Unit Name="Millimetre" Code="MMT" Definition="Millimetre: A millimetre is one thousandth of a metre (0.001)" />
  <Unit Name="Month: Unit of time equal to 1/12 of a year of 365,25 days" Code="MON" Definition="Month: Unit of time equal to 1/12 of a year of 365,25 days" />
  <Unit Name="Square Metre" Code="MTK" Definition="Square metre: A square metre is an area of a square whose sides are exactly 1 metre in length." />
  <Unit Name="Cubic metre" Code="MTQ" Definition="Cubic metre: A cubic metre is the volume of a cube of side length one metre." />
  <Unit Name="Metre" Code="MTR" Definition="Metre: The metre is the basic unit of length in the International System of Units (SI). " />
  <Unit Name="Megawatt Hour " Code="MWH" Definition="Megawatt hour (1000 kW.h): A unit of energy defining the total amount of bulk energy transferred or consumed." />
  <Unit Name="Load" Code="NL" Definition="Load: A unit of volume defining the number of loads (load: a quantity of items carried or processed at one time)." />
  <Unit Name="Ounces Per Square Yard " Code="ON" Definition="Ounces per square yard: The weight of one square yard of the material expressed in ounces.  Commonly used to express the density or weight of all types of paper, paperboard, and fabric, e.g. 20 OZ or 20 weight denim has an area density of 20 oz/yd2. The term density here is used somewhat incorrectly, as density is mass by volume. More precisely, it is a measure of the area density, areal density, or surface density." />
  <Unit Name="Ounce " Code="ONZ" Definition="Ounce:  A unit of mass with several definitions, the most commonly used of which are equal to approximately 30 grams" />
  <Unit Name="Fluid ounce (US)" Code="OZA" Definition="Fluid ounce (US): A fluid ounce (US) is equal to one sixteenth (1/16) of a US pint or   29.5735295625 millilitres." />
  <Unit Name="Fluid ounce (UK)" Code="OZI" Definition="Fluid ounce (UK): A fluid ounce (UK) is equal to one thirtieth (1/30) of a UK pint or 28.4130625 millilitres." />
  <Unit Name="Percent:" Code="P1" Definition="Percent: A unit of proportion equal to 0.01." />
  <Unit Name="Pad " Code="PD" Definition="Pad: A unit of count defining the number of pads (pad: block of paper sheets fastened together at one end)." />
  <Unit Name="Pair" Code="PR" Definition="Pair: A unit of count defining the number of pairs (pair: item described by two's)." />
  <Unit Name="Dry Pint (US)" Code="PTD" Definition="Dry Pint (US): The United States dry pint is equal one eighth of a US dry gallon or one half US dry quarts. It is used in the United States but is not as common as the liquid pint. " />
  <Unit Name="Pint (UK)" Code="PTI" Definition="Pint (UK): A pint (UK) is equal to 1/8 Gallon (UK); used primarily as a measure for beer and cider when sold by the glass." />
  <Unit Name="Liquid pint (US)" Code="PTL" Definition="Liquid pint (US): The US liquid pint is equal one eighth of a United States liquid gallon." />
  <Unit Name="Page - Hardcopy" Code="QB" Definition="Page - hardcopy: A unit of count defining the number of hardcopy pages (hardcopy page: a page rendered as printed or written output on paper, film, or other permanent medium)." />
  <Unit Name="Quart (US dry)" Code="QTD" Definition="Quart (US dry): A US dry quart is equal to 1/32 of a US bushel, exactly 1.101220942715 litres." />
  <Unit Name="Liquid quart (US)" Code="QTL" Definition="Liquid quart (US): A US liquid quart exactly equals 57.75 cubic inches, which is exactly equal to 0.946352946 litres." />
  <Unit Name="Second (unit of time)" Code="SEC" Definition="Second (unit of time): A second is a unit of time equal to 1/60th of a minute." />
  <Unit Name="Set" Code="SET" Definition="Set: A unit of count defining the number of sets (set: a number of objects grouped together)." />
  <Unit Name="Mile (statute mile)" Code="SMI" Definition="Mile (statute mile): A statute mile of 5,280 feet (exactly 1,609.344 meters). " />
  <Unit Name="Serving" Code="SRV" Definition="Serving: The recommended portion of food to be eaten" />
  <Unit Name="Ton (US) or short ton (UK)" Code="STN" Definition="Ton (US) or short ton (UK): Ton (US) = 2000 Lb. or 907 Kg." />
  <Unit Name="Shipment" Code="SX" Definition="Shipment: A unit of count defining the number of shipments (shipment: an amount of goods shipped or transported)." />
  <Unit Name="Tonne" Code="TNE" Definition="Tonne: Metric ton = 1000 Kg" />
  <Unit Name="Tablet " Code="U2" Definition="Tablet: A unit of count defining the number of tablets (tablet: a small flat or compressed solid object)." />
  <Unit Name="Week" Code="WEE" Definition="Week:  A week is a time unit equal to seven days." />
  <Unit Name="Watt hour" Code="WHR" Definition="Watt hour: The watt-hour is a unit of energy equivalent to one watt of power expended for one hour of time; it is equal to 3.6 kilojoules.  The watt-hour is rarely used to express energy in any form other than electrical." />
  <Unit Name="Watt" Code="WTT" Definition="Watt: A watt is a derived unit of power; one watt is equivalent to 1 joule (J) of energy per second." />
  <Unit Name="Nanogram" Code="X_NGM" Definition="Nanogram: A nano gram is 10-9 gram or a billionth of a gram." />
  <Unit Name="Square Yard " Code="YDK" Definition="Square Yard:  A square yard is the area of a square with sides of one yard (three feet, thirty-six inches, 0.9144 metres) in length" />
  <Unit Name="Yard" Code="YRD" Definition="Yard: A yard is It is equal to 3 feet or 36 inches or 0.9144 meter." />
  <Unit Name="Mutually Defined" Code="ZZ" Definition="Mutually Defined: A unit of measure as agreed in common between two or more parties." />
</Units>


-->

</xsl:stylesheet>
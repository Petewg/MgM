AutoFill() : Add auto filling feature to a TextBox Control.
 

Usage :

	-  Build an array for words to filling in text box entry

	- Specify  AutoFill()  as ONCHANGE     procedure of TextBox

	- Specify  AFKeySet()  as ONGOTFOCUS   procedure of TextBox

	- Specify  AFKeyRls( ) as ONLOSTFOCUS  procedure of TextBox
 

Example : 


DEFINE TEXTBOX txbCountry

	ROW         48

	COL         110

	ONCHANGE    AutoFill( aCountries )

	ONGOTFOCUS  AFKeySet( aCountries )

	ONLOSTFOCUS AFKeyRls(  )

END TEXTBOX // txbCountry

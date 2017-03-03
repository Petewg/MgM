	Description of array aButStyles
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

       1 - Style number (used in property "CARGO" for particular button)

       2 - Type of painting
          ( 0 - painting by color defined in property "BACKCOLOR" )
          ( 1 - vertical gradient with one side )
          ( 2 - vertical gradient with two side )
          ( 3 - horizontal gradient with one side )
          ( 4 - horizontal gradient with two side )

       3 - Color of gradient 1 in normal condition
       4 - Color of gradient 2 in normal condition
       5 - Color of gradient 1 at mouse hover
       6 - Color of gradient 2 at mouse hover

       7 - Color of text in normal condition
       8 - Color of text at mouse hover

       9 - Type of border
          (1 - rectangular )
          (2 - round rectangle )

      10 - Color of border in normal condition
      11 - Color of border at mouse hover
 
	Notes
	~~~~~

1. Value of property "CARGO" (character type) - "Style number, file (resource) of picture at mouse hover"
2. If value of property "CARGO" is not defined - style of button is the 1-st line of array aButStyles

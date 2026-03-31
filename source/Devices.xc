; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; 	BASIC FUNCTIONS FOR INPUT CONTROL
; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

; Maximum number of crafters and containers
const $max_prefix_count = 100

; Containers prefix for autocrafting resources
const $container_prefix = "Craft_container{}"
array $container_numbers : number

; Output and tool conveyor names and frequency of outputing items
const $output_conveyor = "Output_conveyor"
const $tool_conveyor = "Tool_conveyor"
const $output_frequency = 1
; Containers prefix for output containers
const $output_prefix = "Output_container{}"
array $output_numbers : number
; Containers prefix for tool containers
;	(used to place tools and consumables like blocks and spools)
const $tool_prefix = "Tool_container{}"
array $tool_numbers : number

; Crafter prefix for autocrafting
const $crafter_prefix = "Crafter{}"
array $crafter_numbers : number
; Stores which crafter numbers are not in use
array $available_crafters : number


var $resource_items : text
var $updated_resources = 0


; Whether there was an error with the crafters
var $is_error = 0


; Keyboard for screen input
const $keyboard = "Craft_keyboard"
; Numpad for screen input
const $numpad = "Craft_numpad"
	
	
	; =-=-=-=-=-=-= G E N E R A L =-=-=-=-=-=-=
		
		
function @_Device_missing($alias:text) : number
	return device_type($alias) == ""

function @Missing_devices() : number	
	if @_Device_missing("Craft_dashboard")
		return 1
		
	foreach $container_numbers ($i, $n)
		if @_Device_missing( text($container_prefix, $n) )
			return 1
			
	foreach $output_numbers ($i, $n)
		if @_Device_missing( text($output_prefix, $n) )
			return 1
			
	foreach $tool_numbers ($i, $n)
		if @_Device_missing( text($tool_prefix, $n) )
			return 1
			
	foreach $crafter_numbers ($i, $n)
		if @_Device_missing( text($crafter_prefix, $n) )
			return 1
			
	return 0
		
		
		
function @error($message:text)
	; Prints an error message and sets the error variable to 1
	if $message
		print($message)
	$is_error = 1
		
function @clear_error()
	; Clears the error variable to 0
	$is_error = 0
	

function @Numpad_val() : number
	; Returns the numpad value
	return input_number($numpad, 0)
	
	
function @Keyboard_val() : text
	; Returns the keyboard sent text
	return input_text($keyboard, 0)
		

; =-=-=-=-=-=-=-=-= L O G I S T I C S =-=-=-=-=-=-=-=-=


function @Container_name($n:number) : text
	; Formats the container number into a container name
	return text($container_prefix, $n)
	
function @Output_name($n:number) : text
	; Formats the container number into a container name
	return text($output_prefix, $n)
	
function @Tool_name($n:number) : text
	; Formats the container number into a container name
	return text($tool_prefix, $n)

function @Stop_conveyor($conv_name:text)
	; Stops the conveyor by putting a filter for "x"
	; To be sure, it also turns the conveyor off and items/second to 1 (minimum)
	output_text($conv_name, 2, "x")
	output_number($conv_name, 0, 0)
	output_number($conv_name, 1, 1)
	
function @Start_conveyor($conv_name:text, $filter:text, $speed:number)
	output_number($conv_name, 1, $speed)
	output_text($conv_name, 2, $filter)
	

function @Stop_output()
	; Stops the output conveyor
	@Stop_conveyor($output_conveyor)
	
function @Stop_tools()
	; Stops the output conveyor
	@Stop_conveyor($tool_conveyor)


function @Add_to_contents($contents:text, $item:text, $amount:number) : text
	if contains(get_recipes("crafter", "SPOOLS"), $item)
		$contents.$item += $amount / 100
	else
		$contents.$item += $amount
	return $contents

function @Get_resource_items() : text
	if $updated_resources
		return $resource_items

	; Sums up all items from the identified containers and returns a K{V} string
	;	This K{V} string will be a collection of all resources available
	var $contents = ""
	if $container_numbers.size
		foreach $container_numbers ($i, $n)
			var $container_contents = input_text(@Container_name($n), 0)
			; Sums the container contents to the overall resources ($contents)
			foreach $container_contents ($j, $t)
				$contents.@Add_to_contents($j, $t)
		
	$updated_resources = 1
	$resource_items = $contents
	return $contents
	
	
function @Get_output_items() : text
	; Sums up all items from the identified output containers and returns a K{V} string
	;	This K{V} string will be a collection of all resources available
	var $contents = ""
	; Output containers
	if $output_numbers.size
		foreach $output_numbers ($i, $n)
			var $output_contents = input_text(@Output_name($n), 0)
			; Sums the container contents to the overall resources ($contents)
			foreach $output_contents ($j, $t)
				$contents.@Add_to_contents($j, $t)
	if $container_numbers.size
		foreach $container_numbers ($i, $n)
			var $container_contents = input_text(@Container_name($n), 0)
			; Sums the container contents to the overall resources ($contents)
			foreach $container_contents ($j, $t)
				$contents.@Add_to_contents($j, $t)
		
	return $contents


function @Get_available_items() : text
	; Sums up all items from the identified containers and returns a K{V} string
	;	This K{V} string will be a collection of all resources available
	var $contents = ""
	; Crafting resource containers
	if $container_numbers.size
		foreach $container_numbers ($i, $n)
			var $container_contents = input_text(@Container_name($n), 0)
			; Sums the container contents to the overall resources ($contents)
			foreach $container_contents ($j, $t)
				$contents.@Add_to_contents($j, $t)
			
	; Output containers
	if $output_numbers.size
		foreach $output_numbers ($i, $n)
			var $output_contents = input_text(@Output_name($n), 0)
			; Sums the container contents to the overall resources ($contents)
			foreach $output_contents ($j, $t)
				$contents.@Add_to_contents($j, $t)
				
	; Tool containers
	if $tool_numbers.size
		foreach $tool_numbers ($i, $n)
			var $tool_contents = input_text(@Tool_name($n), 0)
			; Sums the container contents to the overall resources ($contents)
			foreach $tool_contents ($j, $t)
				$contents.@Add_to_contents($j, $t)
		
	return $contents


function @Get_item_quantity($item:text) : number
	; Gets the number of a specific item in storage
	; IF YOU WOULD LIKE TO SEARCH MULTIPLE ITEMS,
	;  PROBABLY SHOULD USE @Get_available_items DIRECTLY
	if $item == ""
		return 0
	var $available_items = @Get_available_items()
	if $available_items.$item
		return $available_items.$item
	return 0


function @Output_item_list() : text
	; Searches through the resource items to check if
	;		any of those should be in the output containers.
	; Output items are defined as anything outside the "PARTS"
	;   	category, but HDDs are manually included too.
	var $item_list = ""
	array $temp_list : text
	array $crafter_categories : text
	$crafter_categories.from(@Crafter_categories(), ",")
	; Checks each available resource if it should be outputed
	foreach $crafter_categories ($i, $cat)
		if $cat == "PARTS"
			$temp_list.clear()
			$temp_list.append("ARCHEAN_computer.HDD")
		else
			$temp_list.from(@Crafter_category_items($cat), ",")
			
		foreach $temp_list ($j, $item)
			if $resource_items.$item > 0
				$item_list.$item = $resource_items.$item
				
	return $item_list
	

function @Tool_item_list() : text
	; Searches through the resource items to check if
	;		any of those should be in the output containers.
	; Output items are defined as anything outside the "PARTS"
	;   	category, but HDDs are manually included too.
	var $output_items = @Get_output_items()
	var $item_list = ""
	array $temp_list : text
	array $crafter_categories : text
	$crafter_categories.from("CONSTRUCTION,SPOOLS,TOOLS", ",")
	; Checks each available resource if it should be outputed
	foreach $crafter_categories ($i, $cat)
		$temp_list.from(@Crafter_category_items($cat), ",")
			
		foreach $temp_list ($j, $item)
			if $output_items.$item > 0
				$item_list.$item = $output_items.$item
				
	return $item_list


; =-=-=-=-=-=-=-=-= C R A F T I N G =-=-=-=-=-=-=-=-=


function @Crafter_name($n:number) : text
	; Formats the crafter number into a crafter name
	return text($crafter_prefix, $n)
		
		
function @All_crafters_available() : number
	; Checks if the available and all crafters lists are the same size
	return $crafter_numbers.size == $available_crafters.size
	
function @Any_crafters_available() : number
	; Simple check to see if any crafters are available
	return $available_crafters.size > 0
		
		
function @Update_crafter_availability()
	; Updates which crafters are available
	; !! SHOULD RUN *BEFORE* CRAFTING ORDERS IN THE SAME TICK !!
	if @All_crafters_available()
		return
		
	foreach $crafter_numbers ($i, $n)
		var $is_available = 0
		var $c_name = @Crafter_name($n)
		
		; Checks if the crafter is already counted as available,
		; 	so these are not appended to $available_crafters again
		foreach $available_crafters ($j, $n2)
			if $n == $n2
				$is_available = 1
				break
		if $is_available
			continue
		
		; If it is not already counted as available, check if it is crafting or not
		; 	and proceed accordingly
		var $p = @Crafter_progress($c_name)
		if $p == -1
			@error("Error in crafter " & $c_name & " while crafting " & input_text($c_name, 1))
		if $p <= 0 or $p >= 1
			@Cancel_craft($c_name)
			$available_crafters.append($n)
		
	
function @Craft_with_select($item:text) : number
	; Selects an available crafter to craft the item
	; returns 1 if successul and 0 if not
	if @Any_crafters_available()
		@Start_craft(@Crafter_name($available_crafters.last), $item)
		$available_crafters.pop()
		return 1
	return 0
	
	
function @Missing_items($item:text, $quantity:number) : text
	; Gets which and how many items the system does not have in containers
	;	in order to craft a specific $quantity of $item
	var $container_items = @Get_resource_items()
	var $missing_items = ""
	var $recipe = get_recipe("crafter", $item)
	; Checks if the recipe can be done in a crafter
	if $recipe
		foreach $recipe ($k, $v)
			; Skips fluid checks, since we assume to have them
			if $k == "H2" or $k == "O2" or $k == "H2O"
				continue
			; Checks if there are enough items in store
			if $container_items.$k < $v * $quantity
				; Checks if the missing item can be crafted
				if get_recipe("crafter", $k)
					; Appends to the missing items list
					$missing_items.$k = $v * $quantity - $container_items.$k
				else
					@error("Missing item that is not craftable: " & $k)
	else
		@error("Recipe needed can't be done in a crafter: " & $item)
	return $missing_items
	
	
	
	
function @Initialize_devices()

	; Checks which container and crafter numbers exist
	; 	and stores it in the respective arrays
	repeat $max_prefix_count ($i)
		var $dev_name = text($container_prefix, $i+1)
		if device_type($dev_name) == "Container" or device_type($dev_name) == "SmallContainer"
			$container_numbers.append($i+1)
			
		$dev_name = text($output_prefix, $i+1)
		if device_type($dev_name) == "Container" or device_type($dev_name) == "SmallContainer"
			$output_numbers.append($i+1)
			
		$dev_name = text($tool_prefix, $i+1)
		if device_type($dev_name) == "Container" or device_type($dev_name) == "SmallContainer"
			$tool_numbers.append($i+1)
			
		$dev_name = text($crafter_prefix, $i+1)
		if device_type($dev_name) == "Crafter"
			$crafter_numbers.append($i+1)
			
	; Starts all the crafters as available
	foreach $crafter_numbers ($i, $n)
		$available_crafters.append($n)
		
	; Updates the resources available
	@Get_resource_items()
	
	
function @Devices_tick()
	$updated_resources = 0
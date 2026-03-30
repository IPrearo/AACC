; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; 	FUNCTIONS FOR CRAFTING QUEUES AND AUTOCRAFTING
;   BASICALLY, THIS IS THE BASIS FOR AN UI
; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

include "Crafter_functions.xc"
include "Devices.xc"


; Craft stack. Items are crafted from last to first
array $craft_S : text
; Craft Queue. Items are put into the stack from first to last
array $craft_Q : text

; Whether the system was recently crafting something
var $was_crafting = 0

; These values are stored each time the queue or stack get bigger than it
; They can be used for progress bar visualization
storage var $max_craft_Q_size : number
storage var $max_craft_S_size : number

; Whether to autocraft a set of items until a specific amount (0 or non-zero)
storage var $autocraft : number
; Which items to keep in stock and how many of them in a .item{amount} pattern
storage var $autocraft_items : text

; Items whose crafting recipes craft more than 1 unit of it
storage var $multicraft_items : text

; Signals if a queue/stack was recently finished
var $finished_crafting = 0



function @Initialize_crafting()
	@Initialize_devices()
	array $spools : text
	$multicraft_items = ".ARCHEAN_build.SteelRod{100}"
	$spools.clear()
	$spools.from( get_recipes("crafter", "SPOOLS"), "," )
	foreach $spools ($i, $spool)
		$multicraft_items.$spool = 100
	$max_craft_Q_size = 0
	$max_craft_S_size = 0
	
		
function @Cancel_all_craft()
	; Clears both the queue and stack
	$craft_Q.clear()
	$craft_S.clear()
	@clear_error()
		
function @S_append($recipe:text)
	; Appends a recipe to the top of the stack
	; Recipe is a K{V} string
	$craft_S.append($recipe)
	
	
function @S_pop()
	; Pops the recipe at the top of the stack
	$craft_S.pop()
	if $craft_S.size == 0 and $craft_Q.size == 0
		$finished_crafting = 1
	else
		$finished_crafting = 0

		
function @S_top_craft()
	; Crafts the last recipe of the stack
	; Also checks if the last recipe is done
	var $recipe = $craft_S.last
	var $stack_last = size($craft_S)-1
	var $zero_qtty = 0
	var $item_qtty = 0
	foreach $recipe ($item, $quantity)
		; Counts how many items there are in the recipe
		; 	and how many of those are already crafted ($quantity=0)
		$item_qtty++
		if $quantity <= 0
			$zero_qtty++
			continue
			
		; Checks for missing items to craft the item
		var $mi = @Missing_items($item, $quantity)
		; If needed, append missing items to the stack
		if $mi
			@S_append($mi)
			continue
			
		; Else, try to craft 1 of the current item
		; Craft_with_select returns 1 only if it found an available crafter for this
		if @Craft_with_select($item)
			; Updates the amount of items to craft
			$craft_S.$stack_last.$item -= 1
	
	; If all items are crafted, simply pop this recipe
	if $item_qtty == $zero_qtty and @All_crafters_available()
		@S_pop()
		
			
			
function @print_Q()
	; Prints the queue in a decent format
	if $craft_Q.size == 0
		return
	print("Queue:")
	foreach $craft_Q ($i, $item)
		print(text("   {}: {}", $i, $item))
		
function @print_S_root()
	; Prints the stack in a decent format
	if $craft_S.size == 0
		return
	print("Stack root:")
	var $S_root = $craft_S.0
	foreach $S_root ($i, $item)
		print(text("   {}: {}", $i, $item))
			
function @Q_append($item:text)
	; Append an item to last place on crafting queue
	$craft_Q.append($item)
			
function @Q_append_amount($item:text, $amount:number)
	; Append an item to last place on crafting queue
	$craft_Q.append("." & $item & "{" & text($amount) & "}")
	
function @Q_append_single($item:text)
	; Append an item to last place on crafting queue
	$craft_Q.append("." & $item & "{1}")
	
function @Q_progress() : number
	; Progress function based on maximum queue size
	if $max_craft_Q_size
		if $craft_Q.size > $max_craft_Q_size
			$max_craft_Q_size = $craft_Q.size
		return 1-$craft_Q.size/$max_craft_Q_size
	$max_craft_Q_size = $craft_Q.size	
	
	; Fake progress function to show
	if $craft_Q.size
		return 1-pow(2.71828, -$craft_Q.size/3)
	return 1
	
function @S_progress() : number
	; Progress function based on maximum queue size
	if $max_craft_S_size
		if $craft_S.size > $max_craft_S_size
			$max_craft_S_size = $craft_S.size
		return 1-$craft_S.size/$max_craft_S_size
	$max_craft_S_size = $craft_S.size	
	
	; "Fake" progress function to show
	if $craft_S.size
		return 1-pow(2.71828, -$craft_S.size/3)
	return 1
	
function @Current_items() : text
	; Returns the current items being crafted (Stack's last items)
	if $craft_S.size
		return $craft_S.last
	else
		return ""
		
function @Queued_items() : text
	; Gets the queued and stacked items as a .key{value} text
	var $items = ""
	if $craft_S.size
		var $S_item = $craft_S.0
		foreach $S_item ($k, $v)
			$items.$k += $v
	if $craft_Q.size
		foreach $craft_Q ($i, $order)
			foreach $order ($k, $v)
				$items.$k += $v
	return $items
	
function @Crafting_empty() : number
	; Returns 1 if the autocrafting queue AND stack are empty
	if $craft_Q.size or $craft_S.size
		return 0
	return 1
			
			
function @Q_to_S()
	;@print_Q()
	;@print_S_root()
	; Moves the first item of the queue into the stack for crafting
	var $item = $craft_Q.0
	$craft_Q.erase(0)
	@S_append($item)
	; print($item)
	
		
; =-=-=-=-=-=-=-=-= A U T O   C R A F T I N G =-=-=-=-=-=-=-=-=

function @Set_AC_value($item:text, $qtty:number)
	; Overwrites the amount to craft of an item
	if $item
		$autocraft_items.$item = max($qtty, 0)
		
function @Add_AC_value($item:text, $qtty:number)
	; Adds to the amount to craft of an item
	if $item
		$autocraft_items.$item = max($autocraft_items.$item+$qtty, 0)
		
function @Sub_AC_value($item:text, $qtty:number)
	; Substracts from the amount to craft of an item
	if $item
		$autocraft_items.$item = max($autocraft_items.$item-$qtty, 0)
	
function @Get_AC_qtty($item:text) : number
	; Gets the amount to keep in stock for a specific item
	if $item == ""
		return 0
	if $item and $autocraft_items.$item
		return $autocraft_items.$item
	return 0

function @Queued_and_available_items() : text
	; Collection of all available items if the queue and stack gets crafted
	var $Q_items = @Queued_items()
	var $container_items = @Get_available_items()
	foreach $Q_items ($k, $v)
		$container_items.$k += $v
	return $container_items

function @Missing_autocrafting_items()
	; Checks which items are set to be autocrafted but have an inferior amount
	
	; Only does this while the crafting queue and stack are empty,
	;	otherwise it could lead to extra items being crafted due to
	;	the check coinciding with crafters working
	if $craft_Q.size != 0 or $craft_S.size != 0
		return

	var $all_items = @Queued_and_available_items()
	if !size($autocraft_items)
		return
	
	foreach $autocraft_items ($k, $v)
		if $v > $all_items.$k
			; print(text("{}: {}", $k, $v-$all_items.$k))
			if contains($multicraft_items, $k)
				print($k)
				@Q_append_amount($k, ceil(($v-$all_items.$k)/$multicraft_items.$k) )
			else
				@Q_append_amount($k, $v-$all_items.$k)

		
		
timer frequency $output_frequency
	if @Missing_devices()
		return
	; Checks if it wasn't crafting recently to output items
	; This is necessary to stop needed COMPONENTS (category of items)
	; 	 being treated as output
	if !$was_crafting
		; Finds which items need to be sent to the tools containers and sets the conveyor
		var $output_list = @Tool_item_list()
		if $output_list == ""
			@Stop_tools()
		else
			foreach $output_list ($k, $v)
				@Start_conveyor($tool_conveyor, $k, 1000)
				break
		
		; Finds which items need to be outputed and sets the conveyor to do so
		$output_list = @Output_item_list()
		if $output_list == ""
			@Stop_output()
		else
			foreach $output_list ($k, $v)
				@Start_conveyor($output_conveyor, $k, 1000)
				break
		
	else
		@Stop_output()
		@Stop_tools()
		
	$was_crafting = !@Crafting_empty() or !@All_crafters_available()
	
		
update
	if @Missing_devices()
		return
	; If there is an error, stops everything
	if $is_error
		return
		
	; Updates available crafters for this tick
	@Update_crafter_availability()
	
	; Outputs item if the queue and stack are empty
	if @Crafting_empty()
		output_number($output_conveyor, 0, 1)
		output_number($tool_conveyor, 0, 1)
		return
	else
		@Stop_output()
		@Stop_tools()
	
	var $num_available_crafters = $available_crafters.size
	
	repeat $num_available_crafters ($i)
		; Checks if the stack has items to craft
		if $craft_S.size < 1
			if $craft_Q.size < 1
				return
			@Q_to_S()
			
		; Craft the top stack item
		@S_top_craft()
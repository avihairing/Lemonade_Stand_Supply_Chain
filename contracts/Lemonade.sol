pragma solidity >=0.4.22;



//Define a supply Chain Contract "LemonadeStand"
contract LemonadeStand {

//Variable : 'Owner'
address owner;
//Variable : 'skuCount'
uint skuCount;

enum State { ForSale, Sold, Shipped}

//Struct : 'Item' with the following fields : name, sku, price, state, seller, buyer
struct Item {
string name;
uint sku;
uint price;
State state;
address seller;
address buyer;
}

//Mapping : Assign 'Item' a sku
mapping (uint => Item) items;

//Event ForSale
event ForSale(uint skuCount);

//Event Sold
event Sold(uint sku);

event Shipped(uint sku);

//Modifier : Verify Caller
modifier onlyOwner(){
require(msg.sender == owner);
_;
}

modifier verifyCaller(address _address){
require(msg.sender == _address);
_;
}

modifier paidEnough(uint _price){
require(msg.value >= _price);
_;
}

modifier forSale(uint _sku){
require(items[_sku].state == State.ForSale);
_;
}

modifier sold(uint _sku){
require(items[_sku].state == State.Sold);
_;
}

// Define a modifier that checks the price and refunds the remaining balance
modifier checkValue(uint _sku) {
_;
uint _price = items[_sku].price;
uint amountToRefund = msg.value - _price;
items[_sku].buyer.transfer(amountToRefund);
}

constructor() public {
owner = msg.sender;
skuCount = 0;
}


function addItem(string _name, uint _price) onlyOwner public {
//increment sku
skuCount = skuCount + 1;

//emit the appropriate event
emit ForSale(skuCount);

//add the new item into inventory and mark it for sale
items[skuCount] = Item({name : _name, sku : skuCount, price : _price, state : State.ForSale, seller : msg.sender, buyer : 0});
}

function buyItem(uint sku) forSale(sku) paidEnough(items[sku].price) checkValue(sku) public payable{
address buyer = msg.sender;
uint price = items[sku].price;
//update buyer
items[sku].buyer = buyer;
//update state
items[sku].state = State.Sold;
//Transfer money to seller
items[sku].seller.transfer(price);
//emit the appropriate event
emit Sold(sku);
}

function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, string stateIs, address seller, address buyer){
uint state;
name = items[_sku].name;
sku = items[_sku].sku;
price = items[_sku].price;
state = uint(items[_sku].state);
if(state == 0 ) {
stateIs = "For Sale";
}
if(state == 1){
stateIs = "Sold";
}
if(state == 2){
stateIs = "Shipped";
}
seller = items[_sku].seller;
buyer = items[_sku].buyer;
}

// Define a function 'shipItem' that allows the seller to change the state to 'Shipped'
function shipItem(uint sku) public
// Call modifier to check if the item is sold
sold(sku)
// Call modifier to check if the invoker is seller
verifyCaller(items[sku].seller) {
// Update state
items[sku].state = State.Shipped;
// Emit the appropriate event
emit Shipped(sku);

}
}

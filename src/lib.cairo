use  starknet::ContractAddress;

#[starknet::interface]
trait IData <T> {
    fn get_data(self: @T) -> felt252;
    fn set_date(ref self: T, New_value: felt252);
}
#[starknet::interface]
trait ownableTrait <T> {
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn get_Owner(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod Ownable{
    use  starknet::ContractAddress;
    use  starknet::get_caller_address;
    use super::{
        IData,
        ownableTrait
        };

    #[storage]
    struct Storage {
        Owner: ContractAddress,
        value: felt252,
       
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event{
        OwnerShipTransferred: OwnerShipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnerShipTransferred{
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress
    }


    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress ){
        self.Owner.write(initial_owner);
        
    }

    #[external (v0)]
    impl OwnableDataimpl of IData<ContractState> {
        fn get_data(self: @ContractState) -> felt252{
            self.value.read()
        }
    fn set_date(ref self: ContractState, New_value: felt252){
        self.only_Owner();
        self.value.write(New_value);
    }
    }

     #[external (v0)]
    impl OwnersTraitImp of ownableTrait<ContractState>{
         fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress){
            self.only_Owner();
            let prevOwner = self.get_Owner();
            self.Owner.write(new_owner);
            self.emit(Event::OwnerShipTransferred(OwnerShipTransferred{prev_owner: prevOwner, new_owner: new_owner}));
         }

        fn get_Owner(self: @ContractState) -> ContractAddress{
            self.Owner.read()
    }

    }

    #[generate_trait]
    impl OwnableImpl of PrivateMethodsTrait{
    fn only_Owner(self: @ContractState) {
        let caller = get_caller_address();
        assert(caller == self.Owner.read(), 'UnAuthourized')

    }
    }
   
    

}
pragma solidity ^0.6.4;

contract Exchange{
    constructor(address token_addr) public{
        }
    event NewExchange(address indexed token, address indexed exchange);
    
    address public exchangeTemplate;
    uint256 public tokenCount;
     address ZERO_ADDRESS= 0x0000000000000000000000000000000000000000;
    mapping(address=>address) token_to_exchange;
    mapping(address=> address) exchange_to_token;
    mapping(uint256=>address) id_to_token;
    
    function initializeFactory(address template) public{
        assert(exchangeTemplate==ZERO_ADDRESS);
        assert(template!=ZERO_ADDRESS);
        exchangeTemplate=template;
        
    }
    
    function createExchange(address token) public returns(address){
        assert (token != ZERO_ADDRESS);
        assert(exchangeTemplate!=ZERO_ADDRESS);
        assert(token_to_exchange[token]==ZERO_ADDRESS);
        address exchange=exchangeTemplate;
        Exchange(exchange).initializeFactory(token);
        token_to_exchange[token]=exchange;
        exchange_to_token[exchange]=token;
        uint256 token_id=tokenCount+1;
        tokenCount=token_id;
        id_to_token[token_id]=token;
        emit NewExchange(token,exchange);
        return exchange;
    }
    
    function getExchange(address token) public view returns(address){
        return token_to_exchange[token];
    }
    
    function getToken(address exchange) public view returns(address){
        return exchange_to_token[exchange];
    }
    
    function getTokenWithId(uint256 token_id) public view returns(address){
        return id_to_token[token_id];
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
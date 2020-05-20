pragma solidity ^0.6.4;
//title nearswap Exchange Interface V1
//@notice Source code found at https://github.com/uniswap
//@notice Use at your own risk
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
contract Factory {
    function getExchange(address payable token_address) public view returns(address){
        return token_address;
        
    }
}
    
    contract Exchange is Factory{
        

        function ethToTokenTransferOutput(uint256 tokens_bought,address recipient,uint256 deadline) public view returns(uint256){
            return tokens_bought;
            
        }
        //events.
    event TokenPurchase(address indexed buyer, uint256 indexed eth_sold, uint256 indexed tokens_bought);
    event EthPurchase(address indexed buyer, uint256 indexed tokens_sold,uint256 indexed eth_bought);
    event AddLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);
    event RemoveLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    //variables
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    uint256 balance;
    address payable _to;
    uint256 value;
    
    mapping(address=>uint256) balances; //balance of an address
    mapping(address=>uint256) allowances;
    
    
    address ZERO_ADDRESS= 0x0000000000000000000000000000000000000000;
    
    
    address payable token;
    Factory public factory;//interface for contract creator]
    address private Factadd;
constructor(Exchange self,address payable token_addr) public {
    assert(Factadd==ZERO_ADDRESS && token == ZERO_ADDRESS && token_addr != ZERO_ADDRESS);
    Factadd=msg.sender;
    token=token_addr;
    //name=  //nearswap name goes here
    //symbol= //nearswap symbol goes here
    decimals=18;
}

    ERC20 public ERC20Interface;
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens,uint256 _deadline) public payable returns(uint256){
        assert (_deadline > block.number &&(max_tokens>0 && msg.value>0));
        uint256 total_liquidity=totalSupply;
        
        if(total_liquidity>0){
            assert (min_liquidity>0);
            
            uint256 eth_reserve=balances[msg.sender]-msg.value;
            uint256 token_reserve= token.balance;
            uint256 token_amount= msg.value * token_reserve/eth_reserve+1;
            uint256 liquidity_minted= msg.value* total_liquidity/eth_reserve;
            assert (max_tokens>=token_amount && liquidity_minted >= min_liquidity);
            balances[msg.sender]+=liquidity_minted;
            totalSupply=total_liquidity + liquidity_minted;
            assert (ERC20Interface.transferFrom(msg.sender,_to,token_amount));
            emit AddLiquidity(msg.sender,msg.value,token_amount);
            emit Transfer(ZERO_ADDRESS,msg.sender, liquidity_minted);
            return liquidity_minted;
        }
            else{
                assert((Factadd !=ZERO_ADDRESS && token != ZERO_ADDRESS)&& msg.value>=1000000000);
                assert (factory.getExchange(token)==_to);
                uint256 token_amount=max_tokens;
                uint256 initial_liquidity=balances[_to];
                totalSupply=initial_liquidity;
                assert(ERC20Interface.transferFrom(msg.sender,_to,token_amount));
                emit AddLiquidity(msg.sender,msg.value,token_amount);
                emit Transfer(ZERO_ADDRESS,msg.sender,initial_liquidity);
                return initial_liquidity;
                
            }}
                function removeLiquidity(uint256 amount,uint256 min_eth, uint256 min_tokens,uint256 deadline) public returns(uint256,uint256){
                    assert((amount>0 && deadline>block.number)&&(min_eth>0 && min_tokens>0));
                    uint256 total_liquidity=totalSupply;
                    assert (total_liquidity>0);
                    uint256 token_reserve=ERC20Interface.balanceOf(_to);
                    uint256 eth_amount=amount*balance/total_liquidity;
                    uint256 token_amount=(amount*token_reserve)/total_liquidity;
                    assert(eth_amount>=min_eth && token_amount>=min_tokens);
                    balances[msg.sender]-=amount;
                    totalSupply=total_liquidity-amount;
                    msg.sender.send(eth_amount);
                    token.send(token_amount);
                    emit RemoveLiquidity(msg.sender,eth_amount,token_amount);
                    emit Transfer(msg.sender,ZERO_ADDRESS,amount);
                    return (eth_amount,token_amount);
                    
                    
                }
                
                function getInputPrice(uint256 input_amount,uint256 input_reserve,uint256 output_reserve) private view returns(uint256){
                assert(input_reserve>0 && output_reserve>0);
                uint256 input_amount_with_fee=input_amount*997;
                uint256 numerator=input_amount_with_fee*output_reserve;
                uint256 denominator=(input_reserve*1000)+input_amount_with_fee;
                return numerator/denominator;
                }
                
                function getOutputPrice(uint256 output_amount,uint256 input_reserve,uint256 output_reserve) private view returns(uint256){
                assert(input_reserve>0 && output_reserve>0);
                uint256 numerator=input_reserve*output_reserve*1000;
                uint256 denominator=(output_reserve - output_amount) * 997;
                return numerator/denominator+1;
                }
            
                function ethToTokenInput(uint256 eth_sold,uint256 min_tokens,uint256 deadline,address payable buyer,address payable recipient)private returns (uint256){
                   assert (deadline>=block.number && (eth_sold>0 && min_tokens>0));
                   uint256 token_reserve=ERC20Interface.balanceOf(_to);
                   uint256 tokens_bought=getInputPrice(eth_sold,(balance-eth_sold),token_reserve);
                   assert (tokens_bought>=min_tokens);
                  recipient.send(tokens_bought);
                    return tokens_bought;
                   
                }
                
                fallback() external payable{
                    ethToTokenInput(msg.value,1,block.number,msg.sender,msg.sender);
                    
                }
                
                function ethToTokenSwapInput(uint256 min_tokens,address payable recipient,uint256 deadline) public payable returns (uint256){
                    assert (recipient != _to && recipient != ZERO_ADDRESS);
                    return ethToTokenInput(msg.value,min_tokens,deadline,msg.sender,recipient);
                    
                }
                
                 function ethToTokenTransferInput(uint256 min_tokens,uint256 deadline,address payable recipient) public payable returns(uint256){
            assert(recipient != _to &&recipient!=ZERO_ADDRESS);
            
        } 
                
                function ethToTokenOutput(uint256 tokens_bought,uint256 max_eth,uint256 deadline,address payable buyer,address payable recipient) private returns(uint256){
                    assert (deadline>=block.number && (tokens_bought>0 && max_eth>0));
                    uint256 token_reserve=ERC20Interface.balanceOf(_to);
                    uint256 eth_sold=getOutputPrice(tokens_bought,(balance-max_eth),token_reserve);
                    uint256 eth_refund=max_eth-(eth_sold);
                    if(eth_refund>0){
                        buyer.send(eth_refund);
                        token.send(tokens_bought);
                        emit TokenPurchase(buyer,eth_sold,tokens_bought);
                        return(eth_sold);
                    }
                }
               
               function ethToTokenSwapOutput(uint256 tokens_bought,uint256 deadline) public payable returns(uint256){
                  return ethToTokenOutput(tokens_bought,msg.value,deadline,msg.sender,msg.sender); 
               } 
               
               function ethToTokenTransferOutput(uint256 tokens_bought,uint256 deadline,address payable recipient)public payable returns(uint256){
                   assert(recipient != _to && recipient!=ZERO_ADDRESS);
                   return (ethToTokenOutput(tokens_bought,msg.value,deadline,msg.sender,recipient));
               } 

                function tokenToEthInput(uint256 tokens_sold,uint256 min_eth,uint256 deadline,address payable buyer,address payable recipient) private returns(uint256){
                    assert(deadline>=block.number && (tokens_sold>0 && min_eth>0));
                    uint256 token_reserve=ERC20Interface.balanceOf(_to);
                    uint256 eth_bought=getInputPrice(tokens_sold,token_reserve,balance);
                    uint256 wei_bought= eth_bought;
                    assert (wei_bought>=min_eth);
                    recipient.send(wei_bought);
                    assert(ERC20Interface.transferFrom(buyer,_to,tokens_sold));
                    emit EthPurchase(buyer,tokens_sold,wei_bought);
                    return (wei_bought); 
                    
                }
                function tokenToEthSwapInput(uint256 tokens_sold,uint256 min_eth,uint256 deadline) public returns(uint256){
                    return (tokenToEthInput(tokens_sold,min_eth,deadline,msg.sender,msg.sender));
                }
                
                function tokenToEthTransferInput(uint256 tokens_sold,uint256 min_eth,uint256 deadline, address payable recipient) public returns(uint256){
                    assert (recipient!=_to && recipient!= ZERO_ADDRESS);
                    return tokenToEthInput(tokens_sold,min_eth,deadline,msg.sender,recipient);
                    
                }
                
                function tokenToEthOutput(uint256 eth_bought,uint256 max_tokens, uint256 deadline,address payable buyer,address payable recipient) private returns(uint256){
                    assert (deadline>=block.number && eth_bought>0);
                    uint256 token_reserve=ERC20Interface.balanceOf(_to);
                    uint256 tokens_sold=getOutputPrice(eth_bought,token_reserve,balance);
                    assert(max_tokens>=tokens_sold);
                    recipient.send(eth_bought);
                    assert(ERC20Interface.transferFrom(buyer,_to,tokens_sold));
                    emit EthPurchase(buyer,tokens_sold,eth_bought);
                    return(tokens_sold);
                }
                
                function tokenToEthSwapOutput(uint256 eth_bought,uint256 max_tokens,uint256 deadline) public returns(uint256){
                    return(tokenToEthOutput(eth_bought,max_tokens,deadline,msg.sender,msg.sender));

                }
                
                function tokenToEthTransferOutput(uint256 eth_bought,uint256 max_tokens,uint256 deadline,address payable recipient) public returns(uint256){
                    assert(recipient!=_to && recipient !=ZERO_ADDRESS);
                    return(tokenToEthOutput(eth_bought,max_tokens,deadline,msg.sender,recipient));
                    
                } 
                
                function tokenToTokenInput(uint256 tokens_sold,uint256 min_tokens_bought,uint256 min_eth_bought,uint256 deadline,address payable buyer,address payable recipient,address payable exchange_addr) private returns(uint256){
                    assert((deadline>=block.number && tokens_sold>0)&&(min_tokens_bought>0 &&min_eth_bought >0));
                    assert (exchange_addr!=_to && exchange_addr!=ZERO_ADDRESS);
                    uint256 token_reserve=ERC20Interface.balanceOf(_to);
                    uint256 eth_bought=getInputPrice(tokens_sold,token_reserve,balance);
                    uint256 wei_bought=eth_bought;
                    assert(ERC20Interface.transferFrom(buyer,_to,tokens_sold));
                    uint256 tokens_bought=Exchange(exchange_addr).ethToTokenTransferInput(min_tokens_bought,deadline,recipient);
                    value=wei_bought;
                    emit EthPurchase(buyer,tokens_sold,wei_bought);
                    return(tokens_bought);
                    
                }
                
                function tokenToTokenSwapInput(uint256 tokens_sold,uint256 min_tokens_bought,uint256 min_eth_bought,uint256 deadline,address payable token_addr) public returns(uint256){
                    address payable exchange_addr;
                factory.getExchange(token_addr)==exchange_addr;
                    return(tokenToTokenInput(tokens_sold,min_tokens_bought,min_eth_bought,deadline,msg.sender,msg.sender,exchange_addr));
                }
                
                function tokenToTokenTransferInput(uint256 tokens_sold,uint256 min_tokens_bought,uint256 min_eth_bought,uint256 deadline,address payable recipient,address payable token_addr) public returns(uint256){
                    address payable exchange_addr;
                    factory.getExchange(token_addr)==exchange_addr;
                    return tokenToTokenInput(tokens_sold,min_tokens_bought,min_eth_bought,deadline,msg.sender,recipient,exchange_addr);
                }
        
        function tokenToTokenOutput(uint256 tokens_bought,uint256 max_tokens_sold,uint256 max_eth_sold,uint256 deadline,address payable buyer,address payable recipient,address payable exchange_addr) private returns(uint256){
            assert(deadline>=block.number && (tokens_bought>0 &&max_eth_sold>0));
            assert(exchange_addr!=_to && exchange_addr!=ZERO_ADDRESS);
            uint256 eth_bought=Exchange(exchange_addr).getEthToTokenOutputPrice(tokens_bought);
            uint256 token_reserve=ERC20Interface.balanceOf(_to);
            uint256 tokens_sold=getOutputPrice(eth_bought,token_reserve,balance);
            assert(max_tokens_sold>=tokens_sold && max_eth_sold>=eth_bought);
            assert(ERC20Interface.transferFrom(buyer,_to,tokens_sold));
            uint256 eth_sold=Exchange(exchange_addr).ethToTokenTransferOutput(tokens_bought,deadline,recipient);
            uint value=eth_bought;
            emit EthPurchase(buyer,tokens_sold,eth_bought);
            return tokens_sold;
            }
            
        function tokenToTokenSwapOutput(uint256 tokens_bought,uint256 max_tokens_sold,uint256 max_eth_sold,uint256 deadline,address payable token_addr) public returns(uint256){
            address payable exchange_addr;
            factory.getExchange(token_addr)==exchange_addr;
            return tokenToTokenOutput(tokens_bought,max_tokens_sold,max_eth_sold,deadline,msg.sender,msg.sender,exchange_addr);
                 }
        
        function tokenToExchangeSwapinput(uint256 tokens_sold,uint256 min_tokens_bought,uint256 min_eth_bought,uint256 deadline,address payable exchange_addr) public returns(uint256){
            return tokenToTokenInput(tokens_sold,min_tokens_bought,min_eth_bought,deadline,msg.sender,msg.sender,exchange_addr);
        }
        
        function tokenToExchangeTransferInput(uint256 tokens_sold,uint256 min_tokens_bought,uint256 min_eth_bought,uint256 deadline,address payable recipient, address payable exchange_addr) public returns(uint256){
            assert (recipient!=_to);
            return tokenToTokenInput(tokens_sold,min_tokens_bought,min_eth_bought,deadline,msg.sender,recipient,exchange_addr);
        }
        
        function tokenToExchangeSwapOutput(uint256 tokens_bought,uint256 max_tokens_sold,uint256 max_eth_sold,uint256 deadline,address payable exchange_addr) public returns(uint256){
            return tokenToTokenOutput(tokens_bought,max_tokens_sold,max_eth_sold,deadline,msg.sender,msg.sender,exchange_addr);
        }
      
      function tokenToExchangeTransferOutput(uint256 tokens_bought,uint256 max_tokens_sold,uint256 max_eth_sold,uint256 deadline,address payable recipient, address payable exchange_addr) public returns(uint256){
            assert (recipient!=_to);
            return tokenToTokenOutput(tokens_bought,max_tokens_sold,max_eth_sold,deadline,msg.sender,recipient,exchange_addr);
        }
        
        function getEthToTokenInputPrice(uint256 eth_sold) public view returns(uint256){
            assert(eth_sold>0);
            uint256 token_reserve=ERC20Interface.balanceOf(_to);
            return getInputPrice(eth_sold,balance,token_reserve);
        }
        
        function getEthToTokenOutputPrice(uint256 tokens_bought) public view returns(uint256){
            assert(tokens_bought>0);
            uint256 token_reserve=ERC20Interface.balanceOf(_to);
            uint256 eth_sold=getOutputPrice(tokens_bought,balance,token_reserve);
            return eth_sold;
        }
        
        function getTokenToEthInputPrice(uint256 tokens_sold) public view returns(uint256){
            assert(tokens_sold>0);
            uint256 token_reserve=ERC20Interface.balanceOf(_to);
            uint256 eth_bought=getInputPrice(tokens_sold,token_reserve,balance);
      return eth_bought;
            }
            
        function getTokenToEthOutputPrice(uint256 eth_bought) public view returns(uint256){
            assert(eth_bought>0);
            uint256 token_reserve=ERC20Interface.balanceOf(_to);
            return getOutputPrice(eth_bought,token_reserve,balance);
        } 
        
        function tokenAddress() public view returns(address){
            return token;
        }
        
        function factoryAddress() public view returns(Factory){
            return factory;
        }
        
        function balanceOf(address _owner) public view returns(uint256){
            return balances[_owner];
        }
        
        function transfer(address _to,uint256 _value) public returns(bool){
            balances[msg.sender]-=_value;
            balances[_to]+=_value;
            emit Transfer(msg.sender,_to,_value);
            return true;
        }
        
        function transferFrom(address _from,address _to,uint256 _value) public returns(bool){
            balances[_from]-=_value;
            balances[_to]+=_value;
            allowances[_from]-=_value;
            emit Transfer(_from,_to,_value);
            return true;
        }
        
        function approve(address _spender, uint256 _value) public returns(bool){
            allowances[msg.sender]=_value;
            emit Approval(msg.sender,_spender,_value);
            return true;
        }
        function allowance(address _owner,address _spender) public view returns(uint256){
            return allowances[_owner];
        }

}
const express=require('express');
const userRouter=express.Router();
const auth=require('../middlewares/auth');
const {Product}=require('../models/product');
const User = require("../models/user");
const Order = require('../models/order');


userRouter.post('/api/add-to-cart',auth,async(req,res)=>{
    try {
        const {id}=req.body;
        const product=await Product.findById({"_id":id});
    


        // find correct user clicking
        let user=await User.findById(req.user);
        if(user.cart.length==0){
            user.cart.push({product,quantity:1});
        }else{
            let isProductFound=false;
            for (let i = 0; i < user.cart.length; i++) {
                if(user.cart[i].product._id.equals(product._id)){
                    isProductFound=true;
                } 
            }
            if(isProductFound){
                let producttt=user.cart.find((productt)=>productt.product._id.equals(product._id));
                producttt.quantity+=1;
            }else{
            user.cart.push({product,quantity:1});

            }
        }
        user=await user.save();
        res.json(user);

    } catch (error) {
        res.status(500).json({error:error.message});
    }
})


// /api/remove-from-cart/${product.id}

userRouter.delete('/api/remove-from-cart/:id',auth,async(req,res)=>{
    try {
        const {id}=req.params;
        const product=await Product.findById({"_id":id});
    

        // find correct user clicking
        let user=await User.findById(req.user);

        for (let i = 0; i < user.cart.length; i++) {
            if(user.cart[i].product._id.equals(product._id)){
                if(user.cart[i].quantity==1){
                    user.cart.splice(i,1);                    
                }else{
                    user.cart[i].quantity-=1
                }
                
            }
        }
            
        
        user=await user.save();
        res.json(user);

    } catch (error) {
        res.status(500).json({error:error.message});
    }
})


// to save user address

userRouter.post('/api/save-user-address',auth,async(req,res)=>{
try {
    const {address}=req.body;
    let user=await User.findById(req.user);
    user.address=address;
    user=await user.save();
    console.log(user);
    res.json(user);
} catch (error) { 
    res.status(500).json({error:error.message});
}
});

// ordering product
userRouter.post('/api/order',auth,async(req,res)=>{
    try {
        const {cart,totalPrice,address,paymentMethod}=req.body;
        console.log(req.body);
        let products=[];
        for (let i = 0; i < cart.length; i++) {
            let product=await Product.findById(cart[i].product._id);
            if(product.quantity>=cart[i].quantity){
                product.quantity-=cart[i].quantity;
                products.push({product,quantity:cart[i].quantity});
                await product.save();  
            }else{
                return res.status(400).json({msg:`${product.name} is out of stock`})
            } 
            
        }       
        // to make sure cart s empty

        let user=await User.findById(req.user);
        user.cart=[];
        user=await user.save();

        // creating new order
            let order= new Order({
                products,
                totalPrice,
                address,
                userId:req.user,
                orderAt:new Date().getTime(),
                paymentMethod:paymentMethod,
            })
            order=await order.save();
        res.json(order);
    } catch (error) { 
        res.status(500).json({error:error.message});
    }
    });
// get all orders

userRouter.get( '/api/order/me',auth,async (req,res)=>{
    try {
        const orders=await Order.find({userId:req.user});
        res.json(orders);
    } catch (error) {
        res.status(500).json({error:error.message});
        
    }
})
module.exports=userRouter

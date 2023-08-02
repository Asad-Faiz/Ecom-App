const express=require('express');
const adminRouter=express.Router();
const admin=require('../middlewares/admin');
const {Product}=require('../models/product');  
const Order=require('../models/order');

const User = require("../models/user");

// add product
adminRouter.post('/admin/add-Product',admin,async(req,res)=>{
    try {
        const{name,description,images,quantity,price,category}=req.body;
        let product=Product({
            name,
            description,
            images,
            quantity,
            price,
            category
        });
        product=await product.save();
        res.json(product);
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})

// upate product
adminRouter.post('/admin/update-Product',admin,async(req,res)=>{
    try {
        const {_id,name,description,images,quantity,price,category}=req.body;
        let product=  await Product.findById({_id});
        // console.log(product);
        product.name=name;
        product.description=description;
        product.images=images;
        product.quantity=quantity;
        product.price=price;
        product.category=category;


        product=await product.save();
        res.json(product);

        // const{name,description,images,quantity,price,category}=req.body;
        // let product=Product({
        //     name,
        //     description,
        //     images,
        //     quantity,
        //     price,
        //     category
        // });
        // product=await product.save();
        // res.json(product);

        // console.log(req.body);
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})


// get all products
adminRouter.get('/admin/get-products',admin,async(req,res)=>{
    try {
        const products= await Product.find({});
        res.json(products);
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})

// to delete product in post_screen

adminRouter.post('/admin/delete-products',admin,async (req,res)=>{
    try {
        const {id}=req.body;
        let product=await Product.findByIdAndDelete(id);
        
        res.json(product);
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})
// api to get All orders

adminRouter.get('/admin/get-orders',admin,async (req,res)=>{
    try {
        const orders=await Order.find({});
        res.json(orders);
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})

// change status of the order
adminRouter.post('/admin/change-order-status',admin,async (req,res)=>{
    try {
        const {id,status}=req.body;
        let order=  await Order.findById(id);
        let userid=order.userId;
        let user=  await User.findById(userid);
        userToken=user.deviceToken;
        
        
        order.status=status;        
        order=await order.save();
        res.json({order,userToken});
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})

// getting total Earning till now
adminRouter.get('/admin/analytics',admin,async (req,res)=>{
    try {
        const orders=await Order.find({});
        let totalEarnings=0;
        for(let i=0;i<orders.length;i++){
            for(let j=0;j<orders[i].products.length;j++){
                totalEarnings+=orders[i].products[j].quantity*orders[i].products[j].product.price;
            }
        }
        // category wise we serch 5 times because we have 5 categories
        let mobileEarnings= await fetchCategoryWiseProducts('Mobiles'); 
        let essentialEarnings= await fetchCategoryWiseProducts('Essentials'); 
        let applianceEarnings= await fetchCategoryWiseProducts('Appliances'); 
        let bookEarnings= await fetchCategoryWiseProducts('Books'); 
        let fashionEarnings= await fetchCategoryWiseProducts('Fashion'); 
        let earnings={
            totalEarnings,
            mobileEarnings,
            essentialEarnings,
            applianceEarnings,
            bookEarnings,
            fashionEarnings,
        };
        res.json(earnings);
    } catch (error) {
        res.status(500).json({error:error.message});
    }
})
async function fetchCategoryWiseProducts(category) {
    let earning=0;
let categoryOrders=await Order.find({
    'products.product.category':category,
})
for(let i=0;i<categoryOrders.length;i++){
    for(let j=0;j<categoryOrders[i].products.length;j++){
        earning +=categoryOrders[i].products[j].quantity*categoryOrders[i].products[j].product.price;
    }
}
return earning;
}


// to get admin
adminRouter.get('/admin/get-admin',admin,async (req,res)=>{
    try {
        // console.log(1);
   const adminUser=await User.findOne({type:'admin'});
//    console.log(adminUser);
        res.json(adminUser);
    } catch (error) {
        console.log(error);
        res.status(500).json({error:error.message});
    }
})
// to get user
adminRouter.get('/admin/get-user',admin,async (req,res)=>{
    try {
        console.log(1);
   const adminUser=await User.findOne({type:'admin'});
   console.log(adminUser);
        res.json(adminUser);
    } catch (error) {
        console.log(error);
        res.status(500).json({error:error.message});
    }
})
module.exports=adminRouter
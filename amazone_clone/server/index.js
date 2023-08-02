console.log("hello world");
// import from pakages

const express=require("express");
const mongoose=require('mongoose');
// import from Files
const authRouter=require('./routes/auth');
const adminRouter = require("./routes/admin");
const productRouter=require('./routes/product')
const userRouter=require('./routes/user')


// init
const PORT=3000;
const app=express();
const DB="mongodb+srv://asad:asad123@cluster0.5lfzlz3.mongodb.net/?retryWrites=true&w=majority";
// middle where to read other files
app.use(express.json());
app.use(authRouter);
app.use(adminRouter);
app.use(productRouter);
app.use(userRouter);

// api

// connections
mongoose.connect(DB).then(()=>{
    console.log("connection Successfull");
}).catch((e)=>{
    console.log(e);
})
app.listen(PORT,"0.0.0.0",()=>{
    console.log(`Connected to ${PORT}` );
});

const mongoose=require('mongoose');
const ratingSchema=mongoose.Schema({
    userId:{
        type:String,
        required:true,
    },
    rating:{
        type:Number,
        required:true,
        get: (value) => {
            return parseFloat(value.toFixed(2)); // Optional: Round the value to 2 decimal places
          },
          set: (value) => {
            return parseFloat(value.toFixed(2)); // Optional: Round the value to 2 decimal places
          }

    },
});

module.exports=ratingSchema;
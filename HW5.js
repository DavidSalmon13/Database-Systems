// David Schwartzman
// 11/22/2024



// 1) Over how many years was the unemployment data collected?
db.unemployment.aggregate([
    {
        $group: {
            _id: null,
            minYear: { $min: "$Year" },
            maxYear: { $max: "$Year" }
        }
    },
    {
        $project: {
            _id: 0,
            yearsCollected: { $add: [{ $subtract: ["$maxYear", "$minYear"] }, 1] }
        }
    }
])



// 2) How many states were reported on in this dataset?
db.unemployment.aggregate([
    {
  $group:{
  _id:"$State"
  
  }
  
  },
    {
  $count: "Number_of_States "
  }
  
  
  ])

  
  //3) What does this query compute?
db.unemployment.find({Rate : {$lt: 1.0}}).count()

// This query computes the number of documents in the unemployment collection where the Rate field is less than 1.0.



// 4) Find all counties with unemployment rate higher than 10%
db["unemployment"].find(

    {Rate: {$gt:10}},
      {County:1, _id: 0}
  
  
  
  )

  


//5) Calculate the average unemployment rate across all states.
db.unemployment.aggregate([

    {$group:{_id: null, avarageRate:{$avg:"$Rate"}}},
    {$project:{_id:0, avarageRate:1}}
  
  
  ])



  //6) Find all counties with an unemployment rate between 5% and 8%.
  // Assumption: Assumption: I assume I need to include 5 and 8, if I wouldn’t include them it would be $gt and $ls.
  db.unemployment.aggregate([
    {$match:{Rate:{$gte: 5, $lte:8}}},
  
    {$project:{_id:0, "County":1}}
  
  ])



  //7) Find the state with the highest unemployment rate. Hint. Use { $limit: 1 }
  db.unemployment.aggregate([
    {$sort:{Rate:-1}},
  
    {$project:{_id:0, State:1, Rate:1}},
  
    {$limit:1}
  
  
  ])

  

  //8) Count how many counties have an unemployment rate above 5%.
  db.unemployment.aggregate([
	
    {$match: {Rate :{$gt:5}}},
  
    {$count: "Counties "}

  ])



  //9) Calculate the average unemployment rate per state by year.
  db.unemployment.aggregate([

    {$group:{_id:{Year: "$Year", State: "$State"},
      avarageRate : {$avg: "$Rate"}
            }
  },
  
    {$project:{_id : 0, Year : "$_id.Year", State : "$_id.State", avarageRate:1}}	
  
  
  ])
  

  
  //10) (Extra Credit) For each state, calculate the total unemployment rate across all counties (sum of all county rates).
  db.unemployment.aggregate([

    {$group:{_id:"$State", totalRate: {$sum: "$Rate"}}},
  
    {$project:{_id:0, State: "$_id", totalRate:1 }}
  
  
  
  ])

  
  //11) (Extra Credit) The same as Query 10 but for states with data from 2015 onward
  db.unemployment.aggregate([
    {$match: {Year:{$gte: 2015}}},
    {$group:{_id: "$State",totalRate: {$sum: "$Rate"}}},
    
    {$project:{_id:0, State: "$_id", totalRate:1 }}
  
  
  
  ])
  
  





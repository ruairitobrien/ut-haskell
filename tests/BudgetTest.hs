module BudgetTest (tests) where

import Budget (budget)
import Distribution.TestSuite
import Types

twoPartialFills :: TestInstance
twoPartialFills = buildTest result "demand should be filled twice"
  where result
         | closingBalance response /= 150 = Fail "closing balance should be 150"
         | length fillList /= 2 = Fail "there should be two fills"
         | fillEnvelope firstFill /= "Gas" = Fail "the first fill should be for Gas"
         | fillAmount firstFill /= 100 = Fail "the first fill amount should be 100"
         | fillEnvelope secondFill /= "Gas" = Fail "the second fill should be for Gas"
         | fillAmount secondFill /= 100 = Fail "the second fill amount should be 100"
         | otherwise = Pass
        firstFill = head fillList
        secondFill = head $ tail fillList
        fillList = fills response
        response = budget request
        request = BudgetRequest
                    { income = [
                        Income (Date 2015 1 2) 100,
                        Income (Date 2015 1 4) 250
                    ]
                    , demands = [
                        Demand (Period (Date 2015 1 5) (Date 2015 1 5)) "Gas" 200
                    ]
                    , openingBalance = 0
                    }

multipleDemands :: TestInstance
multipleDemands = buildTest result "balance should reduce properly"
  where result
         | closingBalance response /= 50 = Fail "closing balance should be 50"
         | length fillList /= 2 = Fail "there should be two fills"
         | fillEnvelope firstFill /= "Gas" = Fail "the first fill should be for Gas"
         | fillAmount firstFill /= 50 = Fail "the first fill amount should be 50"
         | fillEnvelope secondFill /= "Phone" = Fail "the second fill should be for Phone"
         | fillAmount secondFill /= 100 = Fail "the second fill amount should be 100"
         | otherwise = Pass
        firstFill = head fillList
        secondFill = head $ tail fillList
        fillList = fills response
        response = budget request
        request = BudgetRequest
                    { income = []
                    , demands = [
                        Demand (Period (Date 2015 1 5) (Date 2015 1 5)) "Gas" 50,
                        Demand (Period (Date 2015 1 7) (Date 2015 1 7)) "Phone" 100
                    ]
                    , openingBalance = 200
                    }

singleIncome :: TestInstance
singleIncome = buildTest result "income should contribute to balance"
  where result
         | closingBalance response /= 50 = Fail "closing balance should be 50"
         | length fillList /= 1 = Fail "there should be one fill"
         | fillDate firstFill /= Date 2015 1 2 = Fail "the fill date should be the income date"
         | fillEnvelope firstFill /= "Gas" = Fail "the fill should be for Gas"
         | fillAmount firstFill /= 50 = Fail "the fill amount should be 50"
         | otherwise = Pass
        firstFill = head fillList
        fillList = fills response
        response = budget request
        request = BudgetRequest
                    { income = [
                        Income (Date 2015 1 2) 100
                    ]
                    , demands = [
                        Demand (Period (Date 2015 1 5) (Date 2015 1 5)) "Gas" 50
                    ]
                    , openingBalance = 0
                    }

oneDemandWithBalance :: TestInstance
oneDemandWithBalance = buildTest result "demand should pull from balance"
  where result
         | closingBalance response /= 100 = Fail "closing balance should be 100"
         | length fillList /= 1 = Fail "there should be one fill"
         | fillEnvelope firstFill /= "Gas" = Fail "the fill should be for Gas"
         | otherwise = Pass
        firstFill = head fillList
        fillList = fills response
        response = budget request
        request = BudgetRequest
                    { income = []
                    , demands = [
                        Demand (Period (Date 2015 1 1) (Date 2015 1 1)) "Gas" 100
                    ]
                    , openingBalance = 200
                    }

emptyBudgetRequest :: TestInstance
emptyBudgetRequest = buildTest result "empty budget request should give empty response"
  where result
         | closingBalance response /= 0 = Fail "closing balance should be 0"
         | length fillList /= 0 = Fail "fills should be empty"
         | otherwise = Pass
        fillList = fills response
        response = budget request
        request = BudgetRequest { income = [], demands = [], openingBalance = 0 }


buildTest :: Result -> String -> TestInstance
buildTest result label = TestInstance
  { run = return $ Finished result
  , name = label
  , tags = []
  , options = []
  , setOption = \_ _ -> Right $ buildTest result label
  }

tests :: IO [Test]
tests = return $ map Test
            [ emptyBudgetRequest
            , oneDemandWithBalance
            , singleIncome
            , multipleDemands
            , twoPartialFills
            ]

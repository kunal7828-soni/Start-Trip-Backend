const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.post("/searchTrain", async (req, res) => {

  try {

    const { srcStn, destStn, jrnyDate } = req.body;

    const response = await axios.post(
      "https://www.irctc.co.in/eticketing/protected/mapps1/altAvlEnq/TC",
      {
        srcStn,
        destStn,
        jrnyDate,
        quotaCode: "GN",
      },
      {
        headers: {
          "Content-Type": "application/json",
          "User-Agent": "Mozilla/5.0",
        }
      }
    );

    res.json(response.data);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      error: "Something went wrong"
    });
  }
});

app.listen(3000, () => {
  console.log("Server running");
});
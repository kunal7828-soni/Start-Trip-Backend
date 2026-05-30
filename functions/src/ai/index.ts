import * as functions from "firebase-functions";
import axios from "axios";

export const searchTrain =
functions.https.onRequest(async (req, res) => {
  try {
    // Get data from Flutter
    const {srcStn, destStn, jrnyDate} = req.body;

    // Call IRCTC API
    const response = await axios.post(
      "https://www.irctc.co.in/eticketing/protected/mapps1/altAvlEnq/TC",
      {
        srcStn,
        destStn,
        jrnyDate,
        quotaCode: "GN",
        currentBooking: "false",
        flexiFlag: false,
        handicapFlag: false,
        ticketType: "E",
      },
      {
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "User-Agent": "Mozilla/5.0",
        },
      }
    );

    // Send response to Flutter
    res.status(200).json(response.data);
  } catch (error: any) {
    console.log(error);

    res.status(500).json({
      error: error.message,
    });
  }
});

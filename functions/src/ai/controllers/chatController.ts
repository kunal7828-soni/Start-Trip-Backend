import * as functions from "firebase-functions";
import {generateAIResponse} from "../providers/openaiProvider";

export const tripChatbot = functions.https.onRequest(
  async (req, res) => {
    try {
      const prompt = req.body.prompt;

      const aiResponse = await generateAIResponse(prompt);

      res.status(200).json({
        success: true,
        response: aiResponse,
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        success: false,
        message: "AI request failed",
      });
    }
  }
);

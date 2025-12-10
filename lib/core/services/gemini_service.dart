import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/media_kit/models/media_kit_block.dart';
import '../constants/ai_prompts.dart';

class GeminiService {
  final GenerativeModel? _model;
  final bool _isMock;

  // Initialize with API Key if available, otherwise use Mock mode
  GeminiService(String? apiKey)
      : _isMock = apiKey == null || apiKey.isEmpty,
        _model = (apiKey != null && apiKey.isNotEmpty)
            ? GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey)
            : null;

  Future<Map<String, dynamic>> analyzeContract(String contractText) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 2));
      return {
        "safety_score": 45,
        "risks": [
          {
            "severity": "HIGH",
            "clause": "The Brand shall own all rights to the Content in perpetuity throughout the universe.",
            "explanation": "They own your face forever. You can never revoke this.",
            "fix": "Change to '12 months usage' or 'Digital rights only'"
          },
          {
            "severity": "MEDIUM",
            "clause": "Payment shall be made Net 90 days after publication.",
            "explanation": "Waiting 3 months for payment is bad practice.",
            "fix": "Request Net 30 or Net 15"
          }
        ],
        "negotiation_email": {
          "subject": "Influencer x Brand - Contract Revisions",
          "body": "Hi there,\n\nI've reviewed the agreement and I'm very excited to move forward! I just have two points I'd like to adjust to align with my standard terms:\n\n1. **Usage Rights**: Could we limit the usage to 12 months instead of perpetuity?\n2. **Payment Terms**: I normally work with Net 30 terms. Would that be possible?\n\nLet me know if we can make these updates and send over the final version!\n\nBest,\n[Your Name]"
        }
      };
    }

    try {
      final fullPrompt = "\${AiPrompts.contractScannerSystemInstruction}\n\nCONTRACT TO ANALYZE:\n\$contractText";
      
      final response = await _model!.generateContent([Content.text(fullPrompt)]);
      final text = response.text;
      
      if (text == null) return {"error": "No response"};

      // Clean markdown code blocks if present
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return jsonDecode(cleanText);
    } catch (e) {
      print("Gemini Error: $e");
      return {"error": "Analysis failed", "details": e.toString()};
    }
  }

  Future<String> analyzeImage(Uint8List imageBytes, [String? userPrompt]) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 3));
      return "### 🎨 AESTHETICS REPORT\n\n**Vibe:** Moody, Cinematic, High-Contrast.\n**Palette:** Gold, Black, Teal.\n**Rating:** 8.5/10 - Very consistent!";
    }

    try {
      // Use Flash for vision as it's faster typically, but we instantiated with Pro. Pro is fine.
      final promptText = userPrompt ?? "Analyze the aesthetics of this image. Describe the color palette, mood, and give it a 'Premium Score' out of 10 for an influencer feed.";
      final prompt = TextPart(promptText);
      final imageParts = [DataPart('image/jpeg', imageBytes)];
      
      final response = await _model!.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);

      return response.text ?? "Error: No analysis generated.";
    } catch (e) {
      return "Error analyzing image: $e";
    }
  }

  Future<String> generateBrandPitch(String brandName, String context) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 2));
      return "Hi $brandName team,\n\nI see you're targeting $context. I can help.";
    }
    
    try {
      final prompt = "Write a brand pitch for $brandName. Context: $context";
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? "Error: No pitch generated.";
    } catch (e) {
      return "Error generating pitch: $e";
    }
  }

  Future<String> generateViralScripts(String topic) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 2));
      return "### 🎥 Script 1: The 'Hot Take' Hook\\n\\n**(0:00-0:05)** Face close up. Text: 'Stop doing [Topic] wrong.'\\n**Visual:** Shake head wildly.\\n\\n**(0:05-0:45)** Explain the common mistake vs. your secret hack.\\n\\n**(0:45-0:60)** CTA: 'Follow for more [Niche] secrets.'";
    }
    
    try {
      final prompt = "\${AiPrompts.viralScriptSystemInstruction}\\n\\nTOPIC: \$topic";
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? "Error: No scripts generated.";
    } catch (e) {
      return "Error generating scripts: \$e";
    }
  }

  Future<String> generateColdMail(String brandName, String niche, String followers) async {
    if (_isMock) {
       await Future.delayed(const Duration(seconds: 2));
       return "Subject: Partnership Idea: \$brandName x [Your Handle]\\n\\nHi [Name],\\n\\nI'm a huge fan of \$brandName. I create content in the \$niche space for over \$followers people.\\n\\nI have a concept for a Reels campaign that could drive significant traffic to your new launch.\\n\\nAre you open to a quick chat this week?\\n\\nBest,\\n[Your Name]";
    }

    try {
       final prompt = "Write a high-converting cold email pitch to \$brandName. My niche: \$niche. Followers: \$followers. Keep it short, punchy, and focus on value (ROI). No fluff.";
       final response = await _model!.generateContent([Content.text(prompt)]);
       return response.text ?? "Error generating email.";
    } catch (e) {
      return "Error: \$e";
    }
  }

  Future<List<MediaKitBlock>> generateMediaKit(String userInput) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 4));
      return _getMockMediaKit();
    }

    try {
      final prompt = "\${AiPrompts.mediaKitDesignerSystemInstruction}\\n\\nUSER INPUT:\\n\$userInput";
      // We ask for JSON, so we should ideally set generationConfig to json_mode if the package supports it, 
      // but strictly prompting usually works for 1.5 Pro.
      final response = await _model!.generateContent([Content.text(prompt)]);
      
      final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonList = jsonDecode(cleanJson);
      
      return jsonList.map((e) => MediaKitBlock.fromJson(e)).toList();
    } catch (e) {
      print("Gemini Media Kit Error: \$e");
      // Fallback to mock on error for stability
      return _getMockMediaKit();
    }
  }

  List<MediaKitBlock> _getMockMediaKit() {
    return [
      const MediaKitBlock(type: BlockType.hero, data: {
        "title": "VICTOR • CREATOR",
        "subtitle": "Building the Future, One Line of Code at a Time.",
        "backgroundImageKeyword": "technology"
      }),
      const MediaKitBlock(type: BlockType.stats, data: {
        "metrics": [
          {"label": "Total Reach", "value": "1.2M+", "icon": "eye"},
          {"label": "Instagram", "value": "250K", "icon": "camera"},
          {"label": "Engagement", "value": "8.5%", "icon": "heart"},
        ]
      }),
      const MediaKitBlock(type: BlockType.logos, data: {
        "title": "TRUSTED BY GLOBAL BRANDS",
        "brands": ["Google", "Microsoft", "Notion", "Shopify", "Adidas"]
      }),
      const MediaKitBlock(type: BlockType.pricing, data: {
        "title": "PARTNERSHIP PACKAGES",
        "packages": [
          { "name": "Dedicated Reel", "price": "\$2,500", "features": ["60s Vertical Video", "Usage Rights (3 Months)", "Bio Link"] },
          { "name": "Story Set", "price": "\$800", "features": ["3-Frame Story", "Sticker Link", "24h Duration"] }
        ]
      }),
      const MediaKitBlock(type: BlockType.contact, data: {
        "email": "partners@victor.com",
        "ctaText": "LET'S BUILD TOGETHER"
      }),
    ];
  }

  String _getMockResponse() {
    return """
### 🚨 CONTRACT ANALYSIS REPORT

**Summary:** This contract contains **Significant Risks**. Do not sign without negotiation.

**🚩 RED FLAGS DETECTED:**

*   **🚩 Perpetual Rights (Clause 4.a):** *"The Brand shall own all rights to the Content in perpetuity throughout the universe."*
    *   **Why it's bad:** You lose ownership forever. You can never resell this content or license it elsewhere.
*   **🚩 Exclusivity Trap (Clause 9):** *"Influencer agrees not to promote any other 'lifestyle products' for 12 months."*
    *   **Why it's bad:** "Lifestyle products" is too vague. This could block you from working with *anyone*.
*   **🚩 Payment Terms (Clause 3.b):** *"Payment shall be made Net 90 days after publication."*
    *   **Why it's bad:** Waiting 3 months for payment is unacceptable. Industry standard is Net 30.

**✅ POSITIVE NOTES:**
*   Deliverables are clearly defined.

**RECOMMENDATION:** **REJECT OR RENEGOTIATE**
""";
  }
}

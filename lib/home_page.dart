import 'package:chatgpt/openai_Services.dart';
import 'package:chatgpt/pallete.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'Feature_box.dart';
import 'package:animate_do/animate_do.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final flutterTts = FlutterTts();
  final speechToText = SpeechToText();
  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  final OpenAIService openAIService = OpenAIService();
  int start = 200;
  int delay = 200;
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }
  Future<void> initTextToSpeech() async{
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async{
    await speechToText.initialize();
    setState(() {});
  }
  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }
  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: BounceInDown(
          child: const Text('Humanoid'),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child:Column(
          children: [
             ZoomIn(
          child:Stack(
            children: [
              Center(
              child:Container(
                height: 120,
                width: 120,
                margin: const EdgeInsets.only(top:4),
                decoration: const BoxDecoration(
                  color: Pallete.assistantCircleColor,
                  shape: BoxShape.circle
                ),
              ),
              ),
              Container(
                height: 123,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: AssetImage(
                      "assets/images/virtualAssistant.png"
                  ))
                ),
              )
            ],
          ),
          ),
           FadeInRight(
            child :Visibility(
            visible: generatedImageUrl == null,
            child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
                  vertical: 10
            ),
            margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
              top: 30,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Pallete.borderColor,
              ),
              borderRadius: BorderRadius.circular(20).copyWith(
                topLeft: Radius.zero,
              )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(generatedContent == null ? 
              'Good Morning, What task can i do for you?'
              :generatedContent!,
            style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
                fontSize: generatedContent == null ? 25 : 18,
            ),
            ),
            ),
          ),
          ),
          ),
          if(generatedImageUrl != null) Padding(padding: const EdgeInsets.all(10.0),
          child : ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child:Image.network(generatedImageUrl!),
          )
            ),
          SlideInLeft(
           child:Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child:Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                top: 10,
                left: 22
              ),
              child:const Text('Here are a few Commands', style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
          ),
          ),
          ),
          //Features List
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child:  Column(
            children: [
              SlideInLeft(
                    delay: Duration(milliseconds: start),
                child:const FeatureBox(
                color:Pallete.firstSuggestionBoxColor,
                headerText:'chatgpt',
            DescriptionText: 'A smarter way to stay organized and informed with ChatGPT',
            ),
            ),
              SlideInLeft(
                    delay: Duration(milliseconds: start+delay),
                    child: const FeatureBox(
                color:Pallete.secondSuggestionBoxColor,
                headerText:'Dall-E',
                DescriptionText: 'Get inspired and stay creative woth your personal assistant powered by Dall-E',
              ),
              ),
              SlideInLeft(
                    delay: Duration(milliseconds: start+2*delay),
              child:const FeatureBox(
                color:Pallete.thirdSuggestionBoxColor,
                headerText:'Smart Voice Assistant',
                DescriptionText: 'Get the bost of both worlds with a voice assistant powered by Dall-E and chatGPT',
              ),),
            ],
          ))
        ],
      ),),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child:FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: ()async{
          if(await speechToText.hasPermission &&
          speechToText.isNotListening){
            startListening();
          }else if(speechToText.isListening){
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if(speech.contains('https')){
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() { });
            }else{
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() { });
              await systemSpeak(speech);
            }
            
            await stopListening();
          }else{
            initSpeechToText();
          }
        },
        child: Icon(speechToText.isListening ? Icons.stop:Icons.mic,
        ),
      ),
      ),
    );
  }
}

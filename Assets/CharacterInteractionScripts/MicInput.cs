using UnityEngine;
using System.Collections;


[RequireComponent(typeof(AudioSource))]
public class MicInput : MonoBehaviour {

	public float loudness;

	public string micName;

	public bool detectedSound;
	public float threshold;
    
    public float mean = 0;
    public float sd = 0.00000025f;
    public int n = 1;

    public float talkingTime = 0;
    public float silentTime = 0;

    Animator anim;
    public string talkingTimeParameter = "talkingTime";
    public string silentTimeParameter = "silentTime";
    int talkingTimeParamId;
    int silentTimeParamId;

    //public DetectSpeech detector;

    void Start()
    {
        anim = GetComponent<Animator>();
        talkingTimeParamId = Animator.StringToHash(talkingTimeParameter);
        silentTimeParamId = Animator.StringToHash(silentTimeParameter);

        //_clipRecord = AudioClip.Create();
    }

    //mic initialization
    void InitMic(){
        for(int i = 0; i < Microphone.devices.Length; i++)
        {
            Debug.Log(Microphone.devices[i]);
        }
        //Debug.Log("found " + micName);
        if (micName == null || micName == "") micName = Microphone.devices[0];
        //Debug.Log (micName);
        _clipRecord = Microphone.Start(micName, true, 2, 44100);
        //Debug.Log("started mic");
		detectedSound = false;
        _isInitialized = true;
       // threshold = mean + 2 * (Mathf.Sqrt(sd));
    }

	void StopMicrophone()
	{
		Microphone.End(micName);
        //Debug.Log("stopped mic");
	}


    public AudioClip _clipRecord;//= new AudioClip();
	public int _sampleWindow = 128;

	//get data from microphone into audioclip
	float  LevelMax()
	{
		float levelMax = 0;
		float[] waveData = new float[_sampleWindow];
		int micPosition = Microphone.GetPosition(micName)-(_sampleWindow+1); // null means the first microphone
        //Debug.Log(micPosition + " " + Microphone.GetPosition(micName) + " " + (_sampleWindow + 1));
        if (micPosition < 0) return 0;
		_clipRecord.GetData(waveData, micPosition);
		// Getting a peak on the last 128 samples
		for (int i = 0; i < _sampleWindow; i++) {
			float wavePeak = waveData[i] * waveData[i];
			if (levelMax < wavePeak) {
				levelMax = wavePeak;
			}
		}
		return levelMax;
	}




    void Update()
    {
        // levelMax equals to the highest normalized value power 2, a small number because < 1
        // pass the value to a static var so we can access it from anywhere

        //if (!GetComponent<AudioSource> ().isPlaying 
        //		&& !Microphone.IsRecording (micName)) {
        //	InitMic ();
        //}

        //Debug.Log("micInput.update");

        //Debug.Log(Microphone.GetPosition(micName));

        //print(Microphone.GetPosition(micName) + " " + _sampleWindow);

        if (!_isInitialized)
        {
            InitMic();
        }

  //      if (Microphone.GetPosition (micName) < _sampleWindow) {
  //          Debug.Log("not enough " + Microphone.GetPosition(micName) + " " + _sampleWindow);
  //          silentTime += Time.deltaTime;
  //          return;
		//}
		loudness = LevelMax ();

		if (Time.time > 5.0f && loudness > threshold) {
            //Debug.Log("sound");
			detectedSound = true;
            gameObject.SendMessage("Listen", null, SendMessageOptions.DontRequireReceiver);
            silentTime = 0;
            talkingTime += Time.deltaTime;
        } else
        {
            //Debug.Log("no sound");
            //Debug.Log(Microphone.GetPosition(micName));
            //Debug.Log (loudness);
            silentTime += Time.deltaTime;
            talkingTime = 0;
            if (detectedSound) {
                //print("got speech");
                StopMicrophone();

                gameObject.SendMessage("StopListening", null, SendMessageOptions.DontRequireReceiver);
                //GetComponent<AudioSource> ().clip = _clipRecord;
                //GetComponent<AudioSource> ().Play ();
                //detector.SendMessage("SpeechToText");

                InitMic();
            } else {
                n++;
                float newMean = mean + (loudness - mean) / n;
                sd = sd + (loudness - mean) * (loudness - newMean);
                mean = newMean;
                //threshold = mean + 2 * (Mathf.Sqrt(sd / (n - 1)));

            }
			detectedSound = false;
        }
        anim.SetFloat(talkingTimeParamId, talkingTime);
        anim.SetFloat(silentTimeParamId, silentTime);
	}

	bool _isInitialized;
	// start mic when scene starts
	void OnEnable()
	{
		//InitMic();
		//_isInitialized=true;
        talkingTime = 0;
        silentTime = 0;
    }

	//stop mic when loading a new level or quit application
	void OnDisable()
	{
		StopMicrophone();
	}

	void OnDestroy()
	{
		StopMicrophone();
	}


	// make sure the mic gets started & stopped when application gets focused
	void OnApplicationFocus(bool focus) {

		if (focus && enabled)
		{
			//Debug.Log("Focus");

			if(!_isInitialized){
				//Debug.Log("Init Mic");
				InitMic();
				_isInitialized=true;
			}
		}      
		if (!focus)
		{
			//Debug.Log("Pause");
			StopMicrophone();
			//Debug.Log("Stop Mic");
			_isInitialized=false;

		}
	}
}
using UnityEngine;
using System.Collections;
/*
[System.Serializable]
public class GazeCondition
{
	public string name;
	public float threshold;
	public Transform lookAtTarget;
	public bool startLooking = true;
	public float lookAtTime = 0.5f;
	public float lookAwayTime = 0.3f;
	public float headLookProb = 1.0f;
	public float eyeLookProb = 1.0f;
}
*/
public class LookAt : MonoBehaviour {

    //public GazeCondition [] gazeConditions;
    //public GazeCondition currentGazeCondition;
    //public PatientModel patientModel;

    //public bool startLooking = true;
    public float lookAtTime = 5f;
    public float lookAwayTime = 3f;
    public float headLookProb = 0.5f;
    public float eyeLookProb = 1.0f;

    public float maxXRotation = 45;
    public float maxXEyeRotation = 20;
    public float maxYRotation = 100;
    public float maxYEyeRotation = 45;

    public string LookAtTimeParameterName = "LookAtTime";
    public string LookAwayTimeParameterName = "LookAwayTime";
    int LookAtTimeParamId;
    int LookAwayTimeParamId;

    private Animator anim;
	public Transform lookAtTarget;
	//public Transform [] lookAwayTargets;
	//public float lookAtTime = 0.5f;
	//public float lookAwayTime = 0.3f;
	public float transitionSpeed = 1f;

	//public float headLookProb = 1.0f;
	//public float eyeLookProb = 1.0f;

	float currentHeadWeight = 0.0f;
	float currentEyeWeight = 0.0f;
	float targetHeadWeight = 0.0f;
	float targetEyeWeight = 0.0f;

	//public Transform head;

	float timer = 0.0f;
	bool looking = true;
	//public Transform target;
	Vector3 lookAtPos;

	public Transform eye;

	//public string initialCondition;

	// hwd working
	// not elegant but either tracks the face or looks sideways for the GUi
	//public bool trackface = true;
	


	// hwd working
	//public float timeLook = 6.35f;
	//public bool allowLook = false;


	// Use this for initialization
	void Start () {
		
		anim = GetComponent<Animator>();
		timer = 0;

        LookAtTimeParamId = 0;
        LookAwayTimeParamId = 0;

        foreach (AnimatorControllerParameter param in anim.parameters)
        {
            if (param.name == LookAtTimeParameterName) LookAtTimeParamId = param.nameHash;
            if (param.name == LookAwayTimeParameterName) LookAwayTimeParamId = param.nameHash;
        }

    }

    void Update()
     {
     	timer -= Time.deltaTime;
     }
	
    void LookAtPlayer()
    {
        if (!looking)
        {
            timer = -1;
        }
    }

    void LookAwayFromPlayer()
    {
        if (looking)
        {
            timer = -1;
        }
    }

    void OnAnimatorIK (){

        Vector3 direction = eye.InverseTransformPoint(lookAtTarget.position);
        Quaternion lookRotation = Quaternion.LookRotation(direction);
        float xTurn = Mathf.Abs(lookRotation.eulerAngles.x);
        if(xTurn > 180)
        {
            xTurn = Mathf.Abs(xTurn - 360);
        }
        float yTurn = Mathf.Abs(lookRotation.eulerAngles.y);
        if (yTurn > 180)
        {
            yTurn = Mathf.Abs(yTurn - 360);
        }

        if (timer <= 0f)
		{
            if(LookAtTimeParamId != 0)
            {
                lookAtTime = anim.GetFloat(LookAtTimeParamId);
            }
            if (LookAwayTimeParamId != 0)
            {
                lookAwayTime = anim.GetFloat(LookAwayTimeParamId);
            }
            if (looking || xTurn > maxXRotation || yTurn > maxYRotation)
			{
                timer = lookAwayTime;
                // global, body, head, eyes, clamp (where 0 is unrestrained / 1 is full clamp)
                targetHeadWeight = 0;
				targetEyeWeight = 0;
				looking = false;
			}
			else
			{
				targetHeadWeight = 0;
                if (Random.value < headLookProb || xTurn > maxXEyeRotation || yTurn > maxYEyeRotation)
                {
                        targetHeadWeight =  1.0f;
				}
				targetEyeWeight = 0;
                if (Random.value < eyeLookProb)
                {
                        targetEyeWeight =  1.0f;
				}
				
				// global, body, head, eyes, clamp (where 0 is unrestrained / 1 is full clamp)
				
                timer = lookAtTime;
                looking = true;
			}
		}
		
		if(looking && (xTurn > maxXEyeRotation || yTurn > maxYEyeRotation))
        {
            targetHeadWeight = 1.0f;
        }

        lookAtPos = Vector3.Lerp(lookAtPos, lookAtTarget.position, transitionSpeed * Time.deltaTime);

		
		currentHeadWeight = Mathf.Lerp(currentHeadWeight, targetHeadWeight, transitionSpeed * Time.deltaTime);
		currentEyeWeight = Mathf.Lerp(currentEyeWeight, targetEyeWeight, transitionSpeed * Time.deltaTime);
		
		

		anim.SetLookAtWeight(1.0f,0.0f,currentHeadWeight,currentEyeWeight,0.0f);
		
        anim.SetLookAtPosition (lookAtPos);
       
    }		


}

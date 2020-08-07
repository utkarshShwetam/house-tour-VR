using UnityEngine;
using System.Collections;

public class NodDetector : MonoBehaviour {

    public Transform head;
    Animator anim;
    public float threshold;
    float[] xBuffer;
    float[] yBuffer;
    public int bufferSize = 64;
    int bufferPosition;

    public string nodParameter = "nod";
    public string shakeParameter = "shake";

    Quaternion prevRot;

    // Use this for initialization
    void Start () {
        anim = GetComponent<Animator>();
        prevRot = head.rotation;
        xBuffer = new float[bufferSize];
        yBuffer = new float[bufferSize];
        bufferPosition = 0;
    }

    // Update is called once per frame
    void Update () {
        xBuffer[bufferPosition] = Mathf.Abs(head.rotation.eulerAngles.x - prevRot.eulerAngles.x);
        yBuffer[bufferPosition] = Mathf.Abs(head.rotation.eulerAngles.y - prevRot.eulerAngles.y);
        bufferPosition++;
        if(bufferPosition >= bufferSize)
        {
            bufferPosition = 0;
        }
        float xVel = 0;
        float yVel = 0;
        for(int i = 0; i < bufferSize; i++)
        {
            xVel += xBuffer[i];
            yVel += yBuffer[i];
        }
        xVel /= bufferSize;
        yVel /= bufferSize;
        if (xVel > threshold && yVel < threshold)
        {
            //Debug.Log("nod");
            anim.SetTrigger(nodParameter);
            anim.ResetTrigger(shakeParameter);
        }
        else if (yVel > threshold && xVel < threshold)
        {
            //Debug.Log("shake");
            anim.SetTrigger(shakeParameter);
            anim.ResetTrigger(nodParameter);
        }
        else
        {
            anim.ResetTrigger(shakeParameter);
            anim.ResetTrigger(nodParameter);
        }
        prevRot = head.rotation;
    }
}

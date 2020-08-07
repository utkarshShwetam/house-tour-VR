using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRStandardAssets.Utils;

public class VRInteractiveAnimation : MonoBehaviour {

    // the animator to trigger (if this isn't set it will automatically grab the animator on this game object)
    public Animator m_Animator;

    // the animator parameter to trigger
    public string animatorTrigger;

    // Use this for initialization
    void OnEnable()
    {
        // find the audio source and interactive item if 
        // they aren't already set
        if (m_Animator == null)
        {
            m_Animator = GetComponent<Animator>();
        }
        GetComponent<VRActionHarness>().OnActionTrigger += TriggerAnimation;
    }

    

    // toggles the audio from playing to stopping
    private void TriggerAnimation()
    {
        m_Animator.SetTrigger(animatorTrigger);
    }

}

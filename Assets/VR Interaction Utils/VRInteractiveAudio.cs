using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRStandardAssets.Utils;

public class VRInteractiveAudio : MonoBehaviour
{

    // the audio source to trigger (if this isn't set it will automatically grab the audio source on this game object)
    public AudioSource m_AudioSource;

    // Use this for initialization
    void OnEnable() {
        // find the audio source and interactive item if 
        // they aren't already set
		if(m_AudioSource == null)
        {
            m_AudioSource = GetComponent<AudioSource>();
        }
        GetComponent < VRActionHarness > ().OnActionTrigger += ToggleAudio;
    }

    // Use this for initialization
    void OnDisable()
    {
    }


    // toggles the audio from playing to stopping
    virtual protected void ToggleAudio()
    {
        if (!m_AudioSource.isPlaying)
        {
            m_AudioSource.Play();
        }
        else
        {
            m_AudioSource.Stop();
        }
    }

    
}

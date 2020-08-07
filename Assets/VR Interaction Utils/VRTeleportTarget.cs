using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRStandardAssets.Utils;

public class VRTeleportTarget : MonoBehaviour {

     // the game camera
    [SerializeField]
    private Transform m_TransformToTeleport;
    // the game camera
    [SerializeField]
    private Camera m_Camera;

    private bool m_fading; 

    // Use this for initialization
    void OnEnable()
    {
        GetComponent<VRActionHarness>().OnActionTrigger += Teleport;
        VRCameraFade cameraFade = m_Camera.GetComponent<VRCameraFade>();
        if(cameraFade != null)
        {
            cameraFade.OnFadeComplete += OnFadeComplete;
        }
    }


    
    // toggles the audio from playing to stopping
    private void Teleport()
    {
        Debug.Log("teleport");
        VRCameraFade cameraFade = m_Camera.GetComponent<VRCameraFade>();
        if (cameraFade != null)
        {
            cameraFade.FadeOut(false) ;
            m_fading = true;
        } else
        {
            MoveCamera();
        }

    }

    private void OnFadeComplete()
    {
        if (m_fading)
        {
            m_fading = false;
            MoveCamera();
            VRCameraFade cameraFade = m_Camera.GetComponent<VRCameraFade>();
            cameraFade.FadeIn(false);
        }
    }

    private void MoveCamera()
    {
        m_TransformToTeleport.Translate(transform.position.x - m_Camera.transform.position.x,
                                        0,
                                        transform.position.z - m_Camera.transform.position.z);
    }

}

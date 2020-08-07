using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRStandardAssets.Utils;

public class VRPickUp : MonoBehaviour {

     // where the camera goes when it picks up
    [SerializeField]
    private Transform m_PickUpContainer;
    // the input script, if you want to respond to clicks
    [SerializeField]
    private VRInput m_VRInput;

    public bool returnToLocation;
    public Vector3 pickUpRotation;

    // if the timeout is set it will be automatically 
    // dropped after that time
    public float timeout = 0;

    private bool beingHeld;

    private Transform originalParent;
    private Vector3 originalPosition;
    private Quaternion originalOrientation;
    private bool wasDynamic;



    // Use this for initialization
    void OnEnable()
    {
        GetComponent<VRActionHarness>().OnActionTrigger += PickUp;
        if (m_VRInput)
        {
            m_VRInput.OnDown += HandleDown;
        }
    }


    
    // toggles the audio from playing to stopping
    private void PickUp()
    {
        if (returnToLocation)
        {
            originalParent = transform.parent;
            originalPosition = transform.localPosition;
            originalOrientation = transform.localRotation;
        }
        Rigidbody rigidBody = GetComponent<Rigidbody>();
        if (rigidBody)
        {
            wasDynamic = !rigidBody.isKinematic;
            rigidBody.isKinematic = true;
        } else
        {
            wasDynamic = false;
        }
        transform.parent = m_PickUpContainer;
        transform.localPosition = new Vector3(0, 0, 0);
        transform.localEulerAngles = pickUpRotation;
        beingHeld = true;

        Debug.Log(timeout);
        if(timeout > 000.1)
        {
            StartCoroutine("WaitForDrop");
        }

    }

    private IEnumerator WaitForDrop()
    {
        Debug.Log("waiting for drop");
        yield return new WaitForSeconds(timeout);
        Debug.Log("dropping");
        Drop();
    }

    private void HandleDown()
    {
        Drop();
    }

    private void Drop()
    {
        Debug.Log(gameObject.name);
        if (beingHeld)
        {

            if (wasDynamic)
            {
                Rigidbody rigidBody = GetComponent<Rigidbody>();
                rigidBody.isKinematic = !wasDynamic;
                wasDynamic = false;
            }

            if (returnToLocation)
            {
                 transform.parent = originalParent;
                 transform.localPosition = originalPosition;
                 transform.localRotation = originalOrientation;
            }
            else
            {
                transform.parent = null;
            }
            beingHeld = false;
        }
    }

}

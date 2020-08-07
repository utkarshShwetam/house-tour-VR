using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRStandardAssets.Utils;
using System;

public class VRActionHarness : MonoBehaviour {

    public event Action OnActionTrigger;
    public event Action StartSelection;
    public event Action EndSelection;

    // a selection radial to bring up when selected (if this isn't set it will just trigger the audio immediately
    // without using a selection radial)
    [SerializeField]
    private GazeOnlySelectionRadial m_SelectionRadial;
    // the interactive item that triggers the audio (if this isn't set it will grab the interactive item on this game object)
    [SerializeField]
    private VRInteractiveItem m_InteractiveItem;

    // keeps track of whether the gaze is over the game object
    private bool m_GazeOver;

    // whether the user needs to click to activate the action
    public bool m_RequireClick;

    // Use this for initialization
    void OnEnable()
    {
        // find the interactive item if 
        // they aren't already set
        if (m_InteractiveItem == null)
        {
            m_InteractiveItem = GetComponent<VRInteractiveItem>();
        }

        // add the actions to trigger when the 
        // interactive item is looked at
        m_InteractiveItem.OnOver += HandleOver;
        m_InteractiveItem.OnOut += HandleOut;

        // if there is a selection radial set it up
        if (m_SelectionRadial != null)
        {
            m_SelectionRadial.OnSelectionComplete += HandleSelectionComplete;
            if (!m_RequireClick)
            {
                //StartSelection += SelectionRadial.HandleDown;
                //EndSelection += SelectionRadial.HandleUp;
            }
        }
    }



    void OnDisable()
    {
        // cancel the actions
        m_InteractiveItem.OnOver -= HandleOver;
        m_InteractiveItem.OnOut -= HandleOut;
        if (m_SelectionRadial != null)
        {
            m_SelectionRadial.OnSelectionComplete -= HandleSelectionComplete;
        }
    }

    // triggered when the player looks at the object
    private void HandleOver()
    {

        if (m_SelectionRadial != null)
        {
            // When the user looks at the rendering of the scene, show the radial.
            m_SelectionRadial.Show();
        }
        else
        {
            // if there is no selection radial, just trigger the audio
            OnActionTrigger();
        }
        m_GazeOver = true;
    }


    // triggered when the player stops looking at the object
    private void HandleOut()
    {
        if (m_SelectionRadial != null)
        {
            // cancel the radial
            m_SelectionRadial.Hide();
        }

        m_GazeOver = false;
    }

    // called when the selection radial has completed
    private void HandleSelectionComplete()
    {
        // If the user is looking at the rendering of the scene when the radial's selection finishes, trigger the audio
        if (m_GazeOver)
        {
            m_SelectionRadial.Hide();
            OnActionTrigger();
        }
    }
    

}

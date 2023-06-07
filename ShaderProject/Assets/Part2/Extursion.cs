using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Extursion : MonoBehaviour
{
    public float range;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float f = Mathf.PingPong(Time.time * 0.001f, range) - range / 2;
        GetComponent<MeshRenderer>().materials[0].SetFloat("_Amount", f);
        GetComponent<MeshRenderer>().materials[1].SetFloat("_Amount", f);
    }
}

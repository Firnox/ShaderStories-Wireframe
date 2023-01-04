using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Building : MonoBehaviour {
  [SerializeField] private GameObject windmill;
  [SerializeField] private MeshRenderer windmillMeshRenderer;
  [SerializeField] private MeshRenderer bladesMeshRenderer;
  [SerializeField] private Material wireframeMaterial;
  [SerializeField] private RotateScript bladesRotate;

  // The original materials
  private List<Material> windmillMaterials = new List<Material>();
  private List<Material> bladesMaterials = new List<Material>();
  // The in progress materials
  private List<Material> windmillBuildingMaterials = new List<Material>();
  private List<Material> bladesBuildingMaterials = new List<Material>();

  private bool showingMesh = false;
  private bool showingOverlay = false;

  void Start() {
    // We take a copy of the objects materials so we can replace them later.
    windmillMeshRenderer.GetMaterials(windmillMaterials);
    bladesMeshRenderer.GetMaterials(bladesMaterials);
  }

  public void ToggleOverlay() {
    Shader shader;
    showingOverlay = !showingOverlay;
    if (showingOverlay) {
      shader = Shader.Find("Lit/WireframeOnSurfaceShader");
    } else {
      shader = Shader.Find("Standard");
    }
    foreach (Material material in windmillMaterials) {
      material.shader = shader;
    }
    foreach (Material material in bladesMaterials) {
      material.shader = shader;
    }
  }

  // Switch between wireframe and rendered modes.
  public void ToggleMesh() {
    showingMesh = !showingMesh;
    if (showingMesh) {
      SetFullWireframe();
    } else {
      SetOriginalMaterials();
    }
  }

  public void StartBuilding() {
    showingMesh = false;
    StartCoroutine(build(0.5f, 6f, 2f));
  }

  // Set all mesh materials to wireframe shaders.
  private void SetFullWireframe() {
    windmillBuildingMaterials.Clear();
    bladesBuildingMaterials.Clear();
    foreach (Material material in windmillMaterials) {
      windmillBuildingMaterials.Add(wireframeMaterial);
    }
    foreach (Material material in bladesMaterials) {
      bladesBuildingMaterials.Add(wireframeMaterial);
    }
    windmillMeshRenderer.materials = windmillBuildingMaterials.ToArray();
    bladesMeshRenderer.materials = bladesBuildingMaterials.ToArray();
  }

  // Reset mesh materials to the original ones.
  private void SetOriginalMaterials() {
    windmillMeshRenderer.materials = windmillMaterials.ToArray();
    bladesMeshRenderer.materials = bladesMaterials.ToArray();
  }

  private IEnumerator build(float waitBeforeBuild, float windmillBuildTime, float bladesBuildTime) {
    // Hide the windmill model
    windmill.SetActive(false);
    bladesRotate.rotating = false;
    bladesRotate.ResetRotation();

    // We set our building materials to all wireframe to start with.
    SetFullWireframe();
    
    // Wait before we start to show the build.
    yield return new WaitForSeconds(waitBeforeBuild);
    windmill.SetActive(true);

    // Slight hack for the windmill submeshes aren't in the order I wanted.
    // Should really just reorder them in the model.
    int[] shuffle = new int[5] { 3, 4, 1, 2, 0 };

    // Do the building.
    for (int i = 0; i < windmillBuildingMaterials.Count; i++) {
      yield return new WaitForSeconds(windmillBuildTime / windmillBuildingMaterials.Count);
      windmillBuildingMaterials[shuffle[i]] = windmillMaterials[shuffle[i]];
      windmillMeshRenderer.materials = windmillBuildingMaterials.ToArray();
    }
    for (int i = 0; i < bladesBuildingMaterials.Count; i++) {
      yield return new WaitForSeconds(bladesBuildTime / bladesBuildingMaterials.Count);
      bladesBuildingMaterials[i] = bladesMaterials[i];
      bladesMeshRenderer.materials = bladesBuildingMaterials.ToArray();
    }

    // Set the materials back to the originals and cleanup our wireframe list.
    SetOriginalMaterials();
    // Enable the windmill rotation.
    bladesRotate.rotating = true;
  }
}

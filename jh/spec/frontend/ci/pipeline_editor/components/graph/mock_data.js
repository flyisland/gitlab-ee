export const mockCiYmlWithoutStages = `
job_test_1:
  stage: test
  script:
    - echo "test 1"

job_test_2:
  stage: test
  script:
    - echo "test 2"

job_build:
  stage: build
  script:
    - echo "build"
  needs: ["job_test_2"]
`;

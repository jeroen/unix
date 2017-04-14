context("process stuff")

test_that("process stuff", {
  expect_is(getuid(), "integer")
  expect_is(getgid(), "integer")
  expect_is(getpriority(), "integer")
  
  setpgid()
  expect_equal(getpid(), getpgid())
})

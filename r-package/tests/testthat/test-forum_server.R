context("Testing forum server functions.")

test_that("apply_forum_filters() correctly filters the students.", {
  forum_posts_unfiltered <-
    read_csv("./data/forum_posts_unfiltered.csv")
  forum_posts_filtered <-
    read_csv("./data/forum_posts_filtered.csv")

  expect_equal(
    apply_forum_filters(
      input_df = forum_posts_unfiltered,
      activity_level = "30_min_to_5_hr",
      gender = "male",
      registration_status = "verified",
      category = "All"
    ),
    forum_posts_filtered
  )

})

test_that(
  "calculate_forum_searches() correctly computes the number of searches of each query for the selected filter settings.",
  {
    forum_searches <- read.csv("./data/forum_searches.csv")

    calculated_searches <- tibble(
      Search_Query = c(
        "data science",
        "machine learning",
        "amazon web services",
        "computer science",
        "ggplot",
        "github",
        "regression",
        "statistics"
      ),
      Unique_Users = as.integer(c(3, 2, 1, 1, 1, 1, 1, 1))
    )

    calculated_searches <- calculated_searches %>%
      mutate_if(is.character, as.factor) %>%
      rename(`Search Query` = Search_Query,
             `Unique Users` = Unique_Users)

    expect_equal(
      calculate_forum_searches(
        forum_searches = forum_searches,
        activity_level = "All",
        gender = "All",
        registration_status = "All",
        category = "All"
      ),
      calculated_searches
    )

  }
)

test_that(
  "count_posts() correctly counts the number of posts (including post types) in each subcategory.",
  {
    wrangled_forum_elements <- tibble(
      commentable_id = c("123abc", "234bcd", "345cde"),
      discussion_target = c(
        "General",
        "Programming for Data Science",
        "Computing Platforms for Data Science"
      ),
      display_name = c(
        "General",
        "Block 1, Programming for Data Science",
        "Block 1, Computing Platforms for Data Science"
      ),
      discussion_category = c("General", "Block 1", "Block 1"),
      target_order = c(1, 2, 3),
      category_order = c(1, 2, 2)
    )

    forum_posts_pre_count <-
      read_csv("./data/forum_posts_pre_count.csv")

    forum_posts_post_count <- tibble(
      display_name = c(
        "General",
        "Block 1, Programming for Data Science",
        "Block 1, Computing Platforms for Data Science"
      ),
      posts = c(4, 4, 0),
      Discussion = c(0, 1, 0),
      Question = c(1, 0, 0),
      Response = c(1, 1, 0),
      Comment = c(2, 2, 0)
    ) %>%
      mutate_if(is.integer, as.numeric)

    counted_posts <- count_posts(forum_posts_pre_count,
                                 wrangled_forum_elements = wrangled_forum_elements)
    expect_equal(counted_posts, forum_posts_post_count)

  }
)

test_that("gather_post_types() correctly aggregates the post types.", {
  post_counts_ungathered <- tibble(
    display_name = c(
      "General",
      "Block 1, Programming for Data Science",
      "Block 1, Computing Platforms for Data Science"
    ),
    posts = c(4, 4, 0),
    Discussion = c(0, 1, 0),
    Question = c(1, 0, 0),
    Response = c(1, 1, 0),
    Comment = c(2, 2, 0)
  ) %>%
    mutate_if(is.integer, as.numeric)

  post_counts_gathered <-
    read_csv("./data/post_counts_gathered.csv") %>%
    mutate(`Post Type` = Post_Type) %>%
    select(display_name, `Post Type`, count, tot_posts,-Post_Type) %>%
    mutate_if(is.integer, as.numeric)

  post_counts_gathered$`Post Type` <-
    as.character(post_counts_gathered$`Post Type`)
  post_counts_gathered$`Post Type` <-
    factor(
      post_counts_gathered$`Post Type`,
      levels = c("Comment", "Response", "Question", "Discussion")
    )

  gathered <-
    gather_post_types(post_counts_ungathered, grouping_var = "display_name")

  expect_equal(gathered,
               post_counts_gathered)

})

test_that("get_label_lengths() correctly gets the lengths of each label.", {
  forum_data <- tibble(
    display_name = c(
      "General",
      "Block 1, Programming for Data Science",
      "Block 1, Computing Platforms for Data Science"
    ),
    discussion_category = c("General", "Block 1", "Block 1")
  )

  expect_equal(get_label_lengths(forum_data, category = "All"),
               c(7, 7, 7))

  forum_data_filtered <- forum_data %>%
    filter(discussion_category == "Block 1")

  expect_equal(get_label_lengths(forum_data_filtered, category = "Block 1"),
               c(37, 45))

})

test_that("set_axis_limit() correctly sets the axis limit.", {
  forum_data <- tibble(
    display_name = c(
      "Block 1, Programming for Data Science",
      "Block 1, Computing Platforms for Data Science"
    ),
    posts = c(4, 0),
    Discussion = c(1, 0),
    Question = c(0, 0),
    Response = c(1, 0),
    Comment = c(2, 0),
    views = c(100, 0),
    authors = c(4, 0)
  )
  label_lengths <- c(37, 45)

  computed_axis_limit <-
    set_axis_limit(
      forum_data = forum_data,
      plot_variable = "views",
      label_lengths = label_lengths,
      min_axis_length = 0.1,
      percent_addition_per_char = 0.023
    )

  expect_equal(computed_axis_limit, 185.2)

})

test_that(
  "get_subcategory_options() correctly gets the subcategories for the chosen category.",
  {
    forum_elements <- tibble(
      display_name = c(
        "General",
        "Block 1, Programming for Data Science",
        "Block 1, Computing Platforms for Data Science"
      ),
      discussion_category = c("General", "Block 1", "Block 1")
    )

    expect_equal(get_subcategory_options("All", forum_elements),
                 c("All", "General", "Block 1"))

    filtered_forum_elements <- forum_elements %>%
      filter(discussion_category == "Block 1")

    expect_equal(
      get_subcategory_options("Block 1", filtered_forum_elements),
      c(
        "All",
        "Block 1, Programming for Data Science",
        "Block 1, Computing Platforms for Data Science"
      )
    )
  }
)

########################################################################################
# To run the two tests below, you must first go to forum_server.R and comment out the
# lines that begin with `withProgress` and `incProgress`, in both `get_wordcloud_data()`
# and `update_forum_data()`.
########################################################################################

# test_that("get_wordcloud_data() correctly transforms the forum posts for plotting with a wordcloud.", {
#
#         filtered_wordcloud_data <- read_csv("../data/test_data/forum_server/get_wordcloud_data/filtered_wordcloud_data.csv")
#         filtered_forum_elements <- read_csv("../data/test_data/forum_server/get_wordcloud_data/filtered_forum_elements.csv")
#         wordcloud_all_categories <- read_csv("../data/test_data/forum_server/get_wordcloud_data/wordcloud_all_categories.csv")
#
#         test1 <- get_wordcloud_data(filtered_wordcloud_data = filtered_wordcloud_data,
#                                                        filtered_forum_elements = filtered_forum_elements,
#                                                        category = "All",
#                                                        selected_subcategory = "All")
#
#         test2 <- get_wordcloud_data(filtered_wordcloud_data = filtered_wordcloud_data,
#                                     filtered_forum_elements = filtered_forum_elements,
#                                     category = "Block 1",
#                                     selected_subcategory = "All")
#
#         expect_equal(test1, wordcloud_all_categories)
#
# })

# test_that("update_forum_data() correctly counts all the posts, post types, views, and authors in each subcategory.", {
#
#         forum_posts <- read_csv("../data/test_data/forum_server/update_forum_data/forum_posts.csv")
#         forum_views <- read_csv("../data/test_data/forum_server/update_forum_data/forum_views.csv")
#         forum_elements <- read_csv("../data/test_data/forum_server/update_forum_data/forum_elements.csv")
#         updated_forum_data <- read_csv("../data/test_data/forum_server/update_forum_data/updated_forum_data.csv")
#
#         updated <- update_forum_data(forum_posts = forum_posts,
#                                      forum_views = forum_views,
#                                      forum_elements = forum_elements,
#                                      activity_level = "All",
#                                      registration_status = "All",
#                                      gender = "All",
#                                      category = "All") %>%
#                 mutate_if(is.numeric, as.integer)
#
#         expect_equal(updated, updated_forum_data)
#
# })
